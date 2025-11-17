@echo off
set DATABASE_URL=postgresql://mesteri_user:mesteri_pass@localhost:5432/mesteri_db?schema=public
npx prisma db push --schema prisma/schema.prisma
