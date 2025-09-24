# Scripts Directory

This directory contains various utility and maintenance scripts used during development.

## 🛠️ Script Categories

### **Backend Fix Scripts** (Legacy - Pre-Firebase Migration)
- `fix_backend_errors.ps1` - General backend error fixes
- `fix_backend_errors2.ps1` - Additional backend fixes
- `fix_all_dto_errors.ps1` - DTO validation fixes
- `fix_dto_errors.ps1` - Specific DTO error fixes
- `fix_controller_errors.ps1` - Controller-specific fixes
- `fix_critical_service_issues.ps1` - Service layer fixes
- `fix_parseint_calls.ps1` - Integer parsing fixes
- `final_backend_fixes.ps1` - Final cleanup script

### **Database Scripts**
- `setup-prisma.bat` - Prisma database setup
- `normalize_diacritics.ps1` - Text normalization utilities

### **Development Utilities**
- `apply_changes.py` - Code change application utility
- `inspect.py` - Code inspection tool
- `inspect_context.py` - Context analysis tool
- `fix_extra_close.py` - Code cleanup utility
- `tmp_script.py` - Temporary script file

### **Temporary Files**
- `temp_patch.diff` - Temporary patch file
- `query` - Query file for testing

## 📝 Notes

Most of these scripts were created during the initial development phase to fix various backend issues. With the Firebase migration, many of these will become obsolete as we're replacing custom implementations with Firebase services.

## ⚠️ Status

These scripts are kept for reference but should not be used after Firebase migration is complete.