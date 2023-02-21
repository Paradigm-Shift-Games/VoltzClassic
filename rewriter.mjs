import fs from 'fs/promises'

async function discover(rootPath) {
    const stat = await fs.stat(rootPath);

    if (stat.isFile()) {
        return [rootPath];
    }

    if (stat.isDirectory()) {
        const filePaths = await fs.readdir(rootPath);
        
        const subfilePathPromises = filePaths.map(filePath => {
            return discover(`${rootPath}/${filePath}`);
        });

        const subfilePaths = await Promise.all(subfilePathPromises);

        return subfilePaths.flat();
    }
}

function isLuaSource(file) {
    if (file.endsWith('.lua')) {
        return true;
    }

    if (file.endsWith('.luau')) {
        return true;
    }

    return false;
}

function isMeta(file) {
    if (file.endsWith(`.meta.json`)) {
        return true;
    }

    return false;
}

const files = await discover('./src');
const luaSources = files.filter(isLuaSource);
const metas = files.filter(isMeta);

// delete all metas
for (const meta of metas) {
    fs.unlink(meta);
}

const memoryFiles = await Promise.all(luaSources.map(async file => {
    return {
        path: file,
        // strip CRLF to LF!
        content: await fs.readFile(file, 'utf-8').then(content => content.replace(/\r\n/g, '\n'))
    }
}))

const moduleRegex = /local module = {}/g

function getNewName(memoryFile) {
    const { path } = memoryFile

    const pathSegments = path.split(`/`);
    const pathName = pathSegments[pathSegments.length - 1];

    const nameSegments = pathName.split(`.`);
    const name = nameSegments[0];

    if (name == `init`) {
        return pathSegments[pathSegments.length - 2];
    }
    
    return name
}

function rewriteSource(memoryFile) {
    const newName = getNewName(memoryFile);
    const newSource = memoryFile.content.replaceAll(`module`, newName)

    fs.writeFile(memoryFile.path, newSource);
}

for (const memoryFile of memoryFiles) {
    rewriteSource(memoryFile);
}