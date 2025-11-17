-- AlterTable
ALTER TABLE "users" ADD COLUMN     "availability" TEXT,
ADD COLUMN     "certifications" TEXT[] DEFAULT ARRAY[]::TEXT[],
ADD COLUMN     "insuranceVerified" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "portfolioPhotos" TEXT[] DEFAULT ARRAY[]::TEXT[],
ADD COLUMN     "profilePicture" TEXT,
ADD COLUMN     "skillsTags" TEXT[] DEFAULT ARRAY[]::TEXT[],
ADD COLUMN     "yearsExperience" INTEGER;

-- CreateTable
CREATE TABLE "inspiration_posts" (
    "id" TEXT NOT NULL,
    "craftsmanId" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "beforePhoto" TEXT,
    "afterPhoto" TEXT NOT NULL,
    "additionalPhotos" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "videoUrl" TEXT,
    "skillsShowcased" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "category" TEXT,
    "location" TEXT NOT NULL,
    "city" TEXT NOT NULL,
    "likes" INTEGER NOT NULL DEFAULT 0,
    "views" INTEGER NOT NULL DEFAULT 0,
    "shares" INTEGER NOT NULL DEFAULT 0,
    "isPromoted" BOOLEAN NOT NULL DEFAULT false,
    "promotionEnds" TIMESTAMP(3),
    "promotionBudget" DOUBLE PRECISION,
    "isPublished" BOOLEAN NOT NULL DEFAULT true,
    "isPinned" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "inspiration_posts_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "inspiration_posts_craftsmanId_idx" ON "inspiration_posts"("craftsmanId");

-- CreateIndex
CREATE INDEX "inspiration_posts_createdAt_idx" ON "inspiration_posts"("createdAt");

-- CreateIndex
CREATE INDEX "inspiration_posts_likes_idx" ON "inspiration_posts"("likes");

-- CreateIndex
CREATE INDEX "inspiration_posts_views_idx" ON "inspiration_posts"("views");

-- AddForeignKey
ALTER TABLE "inspiration_posts" ADD CONSTRAINT "inspiration_posts_craftsmanId_fkey" FOREIGN KEY ("craftsmanId") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
