/*
  Warnings:

  - You are about to drop the column `availableTime` on the `User` table. All the data in the column will be lost.
  - You are about to drop the column `energyPatterns` on the `User` table. All the data in the column will be lost.
  - You are about to drop the column `goals_text` on the `User` table. All the data in the column will be lost.
  - You are about to drop the column `incomeGoal` on the `User` table. All the data in the column will be lost.
  - You are about to drop the column `skills` on the `User` table. All the data in the column will be lost.
  - You are about to drop the column `weaknesses` on the `User` table. All the data in the column will be lost.

*/
-- AlterTable
ALTER TABLE "User" DROP COLUMN "availableTime",
DROP COLUMN "energyPatterns",
DROP COLUMN "goals_text",
DROP COLUMN "incomeGoal",
DROP COLUMN "skills",
DROP COLUMN "weaknesses";
