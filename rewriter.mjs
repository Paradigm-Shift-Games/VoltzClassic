import fs from 'fs/promises'
import path from 'path';

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

const files = await discover('./Game/src');
const luaSources = files.filter(isLuaSource);

const memoryFiles = await Promise.all(luaSources.map(async file => {
    return {
        path: file,
        // strip CRLF to LF!
        content: await fs.readFile(file, 'utf-8').then(content => content.replace(/\r\n/g, '\n'))
    }
}))
// const requireRegex = /require\((.+)\)/g;
// const requireRegexLong = /local (.+) = require\((.+)\)/g;
// const serviceRegex = /game:GetService\((.+)\)/g;
// const serviceRegexLong = /local (.+) = game:GetService\((.+)\)/g;

const requireRegex = /local (.+) = require\((.+)\)\n/g;
const serviceRegex = /local (.+) = game:GetService\(['"](.+)['"]\)\n/g;
const authorRegex = /--\s*Author(.+)\n/g;

function rewriteSource(memoryFile) {
    const { path, content } = memoryFile;
    // Get all of the service statements
    const serviceMatches = [...content.matchAll(serviceRegex)];
    // Get all of the require statements
    const requireMatches = [...content.matchAll(requireRegex)];
    // Get all of the author statements
    const authorMatches = [...content.matchAll(authorRegex)];
    console.log(serviceMatches.length);
    console.log(requireMatches.length);
    console.log(authorMatches.length);
    // Ensure every service's local name matches the service name
    for (const serviceMatch of serviceMatches) {
        const [, localName, serviceName] = serviceMatch;
        if (localName !== serviceName) {
            throw new Error(`Service name mismatch in ${path}, ${localName} !== ${serviceName}`);
        }
    }
    // Create objects for every require call
    const requireObjects = requireMatches.map(requireMatch => {
        const [, localName, requirePath] = requireMatch;
        return {
            localName,
            requirePath
        }
    })
    // Create a set of every existing service
    const serviceSet = new Set(serviceMatches.map(serviceMatch => {
        const [, serviceName] = serviceMatch;
        return serviceName;
    }));
    // Convert all 'game.Service' calls to 'Service'
    // Additionally, add them to the service set so they can be converted to locals
    for (const requireObject of requireObjects) {
        const { localName, requirePath } = requireObject;
        const segments = requirePath.split('.');
        if (segments[0] === 'game') {
            if (segments.length < 2) {
                throw new Error(`Invalid require path in ${path}, ${requirePath}`);
            }
            serviceSet.add(segments[1]);
            
            const newSegments = [];
            for (let i = 1; i < segments.length; i++) {
                newSegments.push(segments[i]);
            }
            requireObject.requirePath = newSegments.join('.');
        }
    }
    // Remove all of the service, require, and author statements
    const cleansedContent = content
        .replace(serviceRegex, ``)
        .replace(requireRegex, ``)
        .replace(authorRegex, ``);
    // Create a list of all of the author statements
    const authorStatements = authorMatches.map(authorMatch => {
        const [, authorSignature] = authorMatch;
        return `-- Author${authorSignature}`;
    });
    // Create a list of all of the local service statements
    const serviceStatements = [...serviceSet].map(serviceName => {
        return `local ${serviceName} = game:GetService("${serviceName}")`;
    });
    // Create a list of all of the local require statements
    const requireStatements = requireObjects.map(requireObject => {
        const { localName, requirePath } = requireObject;
        return `local ${localName} = require(${requirePath})`;
    });
    // Sort all of the statements by length, shortest first
    const sortedAuthorStatements = authorStatements.sort((a, b) => a.length - b.length);
    const sortedServiceStatements = serviceStatements.sort((a, b) => a.length - b.length);
    const sortedRequireStatements = requireStatements.sort((a, b) => a.length - b.length);
    // Create blocks of statements
    const authorBlock = sortedAuthorStatements.join('\n');
    const serviceBlock = sortedServiceStatements.join('\n');
    const requireBlock = sortedRequireStatements.join('\n');
    let newContent = ""
    if (authorBlock) {
        newContent += `${authorBlock}\n\n`;
    }
    if (serviceBlock) {
        newContent += `${serviceBlock}\n\n`;
    }
    if (requireBlock) {
        newContent += `${requireBlock}\n\n`;
    }
    newContent += cleansedContent;
    // Write the new file content
    fs.writeFile(path, newContent);
}

for (const memoryFile of memoryFiles) {
    rewriteSource(memoryFile);
}