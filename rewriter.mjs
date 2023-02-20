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

const fnRegex = /(\w+)\.(\w+) = function\(([\w, \,,\ ]+)\)/g

function rewriteSource(memoryFile) {
    const newContent = memoryFile.content.replaceAll(fnRegex, (...args) => {
        const [fileContent, moduleName, functionName, argumentList] = args
        return `function ${moduleName}.${functionName}(${argumentList})`
    })

    // Write the new file content
    fs.writeFile(memoryFile.path, newContent);
}

for (const memoryFile of memoryFiles) {
    rewriteSource(memoryFile);
}