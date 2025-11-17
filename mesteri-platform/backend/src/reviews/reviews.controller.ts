import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Param,
  Body,
  UseGuards,
  Query,
} from '@nestjs/common';
import { ReviewsService } from './reviews.service';
import type { Review } from '@prisma/client';
import { FirebaseAuthGuard } from '../guards/firebase-auth.guard';

@Controller('reviews')
@UseGuards(FirebaseAuthGuard)
export class ReviewsController {
  constructor(private readonly reviewsService: ReviewsService) {}

  @Get()
  async findAll() {
    return await this.reviewsService.findAllReviews();
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    return await this.reviewsService.findReviewById(id);
  }

  @Get('user/:userId')
  async findByUserId(@Param('userId') userId: string) {
    return await this.reviewsService.findReviewsByUserId(userId);
  }

  @Get('reviewer/:userId')
  findByReviewerId(@Param('userId') userId: string) {
    return this.reviewsService.findReviewsByReviewerId(userId);
  }

  @Get('project/:projectId')
  findByProjectId(@Param('projectId') projectId: string) {
    return this.reviewsService.findReviewsByProjectId(projectId);
  }

  @Get('rating/:rating')
  findByRating(@Param('rating') rating: string) {
    return this.reviewsService.findReviewsByRating(parseInt(rating));
  }

  @Get('tag/:tag')
  findByTag(@Param('tag') tag: string) {
    return this.reviewsService.findReviewsByTag(tag);
  }

  @Put(':id')
  update(@Param('id') id: string, @Body() updateData: Partial<Review>) {
    return this.reviewsService.updateReview(id, updateData);
  }

  @Delete(':id')
  delete(@Param('id') id: string) {
    return this.reviewsService.deleteReview(id);
  }

  @Post(':id/approve')
  approveReview(@Param('id') id: string) {
    return this.reviewsService.approveReview(id);
  }

  @Post(':id/reject')
  rejectReview(@Param('id') id: string, @Body('reason') reason: string) {
    return this.reviewsService.rejectReview(id, reason);
  }

  @Post(':id/report')
  reportReview(@Param('id') id: string, @Body('reason') reason: string) {
    return this.reviewsService.reportReview(id, reason);
  }

  @Post(':id/helpful')
  markAsHelpful(
    @Param('id') id: string,
    @Body('isHelpful') isHelpful: boolean,
  ) {
    return this.reviewsService.markAsHelpful(id, isHelpful);
  }

  @Get('stats')
  getReviewStats(@Query('userId') userId?: string) {
    return this.reviewsService.getReviewStats(userId);
  }

  @Get('top-rated')
  getTopRatedUsers(
    @Query('minReviews') minReviews?: string,
    @Query('minRating') minRating?: string,
  ) {
    return this.reviewsService.getTopRatedUsers(
      minReviews ? parseInt(minReviews) : 5,
      minRating ? parseFloat(minRating) : 4.5,
    );
  }

  @Get('recent')
  getRecentReviews(@Query('limit') limit?: string) {
    return this.reviewsService.getRecentReviews(limit ? parseInt(limit) : 10);
  }

  @Get('search')
  searchReviews(@Query('q') query: string) {
    return this.reviewsService.searchReviews(query);
  }

  @Get('trending')
  getTrendingReviews(@Query('days') days?: string) {
    return this.reviewsService.getTrendingReviews(days ? parseInt(days) : 7);
  }
}
