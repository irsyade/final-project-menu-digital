import 'dart:io';

void main() {
  final logFile = File(r'C:\Users\COMPUTER\.gemini\antigravity\brain\b86ecef0-10d2-4a53-a778-10c7174cb669\.system_generated\tasks\task-651.log');
  if (!logFile.existsSync()) {
    print('Log file not found');
    return;
  }
  
  final lines = logFile.readAsLinesSync();
  final Map<String, Set<int>> fileErrors = {};
  
  for (final line in lines) {
    if (line.contains('invalid_constant') || line.contains('non_constant_list_element')) {
      final parts = line.split(' - ');
      if (parts.length >= 3) {
        final locPart = parts[2].trim();
        final locParts = locPart.split(':');
        if (locParts.length >= 2) {
          final filePath = locParts[0].replaceAll('\\', '/');
          final lineNum = int.tryParse(locParts[1]);
          if (lineNum != null) {
            final fullPath = 'c:/laragon/www/final project/mobile_flutter/$filePath';
            fileErrors.putIfAbsent(fullPath, () => {}).add(lineNum);
          }
        }
      }
    }
  }
  
  print('Found errors in ${fileErrors.length} files');
  
  for (final entry in fileErrors.entries) {
    final filePath = entry.key;
    final lineNums = entry.value;
    final file = File(filePath);
    if (!file.existsSync()) {
      print('File not found: $filePath');
      continue;
    }
    
    // Sort lines in descending order to process from bottom to top of file
    final sortedLines = lineNums.toList()..sort((a, b) => b.compareTo(a));
    
    final fileLines = file.readAsLinesSync();
    print('Processing $filePath: ${sortedLines.length} errors');
    
    for (final lineNum in sortedLines) {
      final idx = lineNum - 1;
      if (idx < 0 || idx >= fileLines.length) continue;
      
      // Look upwards to find the nearest line containing "const "
      int checkIdx = idx;
      bool found = false;
      while (checkIdx >= 0 && checkIdx >= idx - 15) {
        final line = fileLines[checkIdx];
        if (line.contains('const ')) {
          final newLine = line.replaceAll('const ', '');
          if (newLine != line) {
            print('Line ${checkIdx + 1} (referencing line $lineNum):\n  - $line\n  + $newLine');
            fileLines[checkIdx] = newLine;
            found = true;
            break;
          }
        }
        checkIdx--;
      }
      
      if (!found) {
        // Fallback: strip const from list declarations like children: const [
        checkIdx = idx;
        while (checkIdx >= 0 && checkIdx >= idx - 15) {
          final line = fileLines[checkIdx];
          if (line.contains('const[')) {
            final newLine = line.replaceAll('const[', '[');
            print('Line ${checkIdx + 1} (referencing line $lineNum):\n  - $line\n  + $newLine');
            fileLines[checkIdx] = newLine;
            found = true;
            break;
          }
          checkIdx--;
        }
      }
    }
    
    file.writeAsStringSync(fileLines.join('\n'));
  }
  
  print('Done!');
}
