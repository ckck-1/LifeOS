/*
  Warnings:

  - Made the column `currentValue` on table `Goal` required. This step will fail if there are existing NULL values in that column.

*/
-- AlterTable
ALTER TABLE "Goal" ADD COLUMN     "expiresAt" TIMESTAMP(3),
ADD COLUMN     "progress" DOUBLE PRECISION NOT NULL DEFAULT 0,
ADD COLUMN     "status" TEXT NOT NULL DEFAULT 'active',
ALTER COLUMN "currentValue" SET NOT NULL;
