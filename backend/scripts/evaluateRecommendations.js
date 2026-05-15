const path = require('path');
const { runPython, printPythonHelp } = require('./pythonRunner');

const backendDir = path.resolve(__dirname, '..');
const evaluateScript = path.join(backendDir, 'recommender', 'evaluate_model.py');

const { result, attempts } = runPython(evaluateScript, [], { cwd: backendDir });

if (!result) {
  printPythonHelp(attempts);
  process.exit(1);
}

if (result.stdout) {
  process.stdout.write(result.stdout);
}
if (result.stderr) {
  process.stderr.write(result.stderr);
}

process.exit(result.status || 0);
