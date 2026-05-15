const { spawnSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const backendDir = path.resolve(__dirname, '..');
const localPython = path.join(backendDir, '.tools', 'reco-env', 'python.exe');

const candidates = process.env.PYTHON
  ? [{ command: process.env.PYTHON, args: [] }]
  : [
      ...(fs.existsSync(localPython) ? [{ command: localPython, args: [] }] : []),
      { command: 'python', args: [] },
      { command: 'py', args: ['-3'] },
      { command: 'python3', args: [] }
    ];

function runPython(scriptPath, args, options) {
  const attempts = [];

  for (const candidate of candidates) {
    const result = spawnSync(
      candidate.command,
      [...candidate.args, scriptPath, ...args],
      {
        ...options,
        encoding: 'utf8'
      }
    );

    if (!result.error && !looksLikeBrokenPython(result)) {
      return { result, command: [candidate.command, ...candidate.args].join(' ') };
    }

    attempts.push({
      command: [candidate.command, ...candidate.args].join(' '),
      error: result.error ? result.error.message : result.stderr || result.stdout
    });
  }

  return { result: null, command: null, attempts };
}

function looksLikeBrokenPython(result) {
  const output = `${result.stderr || ''}\n${result.stdout || ''}`;
  return output.includes('unable to load the file system codec')
    || output.includes("No module named 'encodings'")
    || output.includes('Python 3 not found');
}

function printPythonHelp(attempts) {
  console.error('Could not find a working Python 3 install for the recommender.');
  console.error('');
  console.error('Tried:');
  for (const attempt of attempts) {
    console.error(`- ${attempt.command}: ${String(attempt.error || '').trim() || 'failed'}`);
  }
  console.error('');
  console.error('Fix: install Python 3 or Miniconda, then run:');
  console.error('  python -m pip install -r recommender/requirements.txt');
  console.error('');
  console.error('If your Python command is different, set it first, for example:');
  console.error('  $env:PYTHON="C:\\Path\\To\\python.exe"');
}

module.exports = { runPython, printPythonHelp };
