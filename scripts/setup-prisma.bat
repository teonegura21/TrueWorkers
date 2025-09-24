@echo off
cd /d "mesteri-platform/backend"
set DATABASE_URL=postgresql://mesteri_user:mesteri_pass@localhost:5432/mesteri_db?schema=public
echo ℹ️  Working directory: %CD%
echo ℹ️  Prisma Schema: prisma/schema.prisma
echo ℹ️  Database URL set to: %DATABASE_URL%
echo.
echo 🔄 Generating Prisma Client...
call npx prisma generate
echo.
echo 📦 Pushing schema to database...
call npx prisma db push --accept-data-loss
echo.
echo dY"< Running database seed...
call npx prisma db seed
echo.
echo ✨ Migration completed successfully!
echo.
echo 📋 Next steps:
echo   1. Verify your database with: npx prisma studio
echo   2. Run your NestJS app: npm run start:dev
echo   3. Proceed to Phase 2: Remove TypeORM dependencies
pause
