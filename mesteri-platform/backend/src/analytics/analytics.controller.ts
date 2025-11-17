import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Param,
  Body,
  Query,
  UseGuards,
} from '@nestjs/common';
import { AnalyticsService, type TrackEventDto, type SearchHistoryDto, type SavedCraftsmanDto, type AnalyticsEventType } from './analytics.service';
import { FirebaseAuthGuard } from '../guards/firebase-auth.guard';

@Controller('analytics')
@UseGuards(FirebaseAuthGuard)
export class AnalyticsController {
  constructor(private readonly analyticsService: AnalyticsService) {}

  // ========== ANALYTICS EVENTS ==========

  @Post('events')
  trackEvent(@Body() data: TrackEventDto) {
    return this.analyticsService.trackEvent(data);
  }

  @Get('events/user/:userId')
  getUserEvents(
    @Param('userId') userId: string,
    @Query('limit') limit?: string,
  ) {
    return this.analyticsService.getUserEvents(
      userId,
      limit ? parseInt(limit) : 100,
    );
  }

  @Get('events/type/:type')
  getEventsByType(
    @Param('type') type: AnalyticsEventType,
    @Query('limit') limit?: string,
  ) {
    return this.analyticsService.getEventsByType(
      type,
      limit ? parseInt(limit) : 100,
    );
  }

  @Get('events/range')
  getEventsInRange(
    @Query('start') start: string,
    @Query('end') end: string,
  ) {
    return this.analyticsService.getEventsInRange(
      new Date(start),
      new Date(end),
    );
  }

  @Get('events/stats')
  getEventStats(@Query('userId') userId?: string) {
    return this.analyticsService.getEventStats(userId);
  }

  // ========== SEARCH HISTORY ==========

  @Post('search')
  recordSearch(@Body() data: SearchHistoryDto) {
    return this.analyticsService.recordSearch(data);
  }

  @Get('search/user/:userId')
  getUserSearchHistory(
    @Param('userId') userId: string,
    @Query('limit') limit?: string,
  ) {
    return this.analyticsService.getUserSearchHistory(
      userId,
      limit ? parseInt(limit) : 50,
    );
  }

  @Get('search/popular')
  getPopularSearches(@Query('limit') limit?: string) {
    return this.analyticsService.getPopularSearches(
      limit ? parseInt(limit) : 10,
    );
  }

  @Get('search/suggestions/:userId')
  getSearchSuggestions(
    @Param('userId') userId: string,
    @Query('q') query: string,
    @Query('limit') limit?: string,
  ) {
    return this.analyticsService.getSearchSuggestions(
      userId,
      query,
      limit ? parseInt(limit) : 5,
    );
  }

  @Delete('search/user/:userId')
  clearSearchHistory(@Param('userId') userId: string) {
    return this.analyticsService.clearSearchHistory(userId);
  }

  @Post('search/:searchId/click/:resultId')
  recordSearchClick(
    @Param('searchId') searchId: string,
    @Param('resultId') resultId: string,
  ) {
    return this.analyticsService.recordSearchClick(searchId, resultId);
  }

  // ========== SAVED CRAFTSMEN ==========

  @Post('saved-craftsmen')
  saveCraftsman(@Body() data: SavedCraftsmanDto) {
    return this.analyticsService.saveCraftsman(data);
  }

  @Delete('saved-craftsmen/:userId/:craftsmanId')
  unsaveCraftsman(
    @Param('userId') userId: string,
    @Param('craftsmanId') craftsmanId: string,
  ) {
    return this.analyticsService.unsaveCraftsman(userId, craftsmanId);
  }

  @Get('saved-craftsmen/:userId')
  getSavedCraftsmen(@Param('userId') userId: string) {
    return this.analyticsService.getSavedCraftsmen(userId);
  }

  @Get('saved-craftsmen/:userId/:craftsmanId/check')
  isCraftsmanSaved(
    @Param('userId') userId: string,
    @Param('craftsmanId') craftsmanId: string,
  ) {
    return this.analyticsService.isCraftsmanSaved(userId, craftsmanId);
  }

  @Put('saved-craftsmen/:userId/:craftsmanId')
  updateSavedCraftsman(
    @Param('userId') userId: string,
    @Param('craftsmanId') craftsmanId: string,
    @Body() data: { notes?: string; tags?: string[] },
  ) {
    return this.analyticsService.updateSavedCraftsman(userId, craftsmanId, data);
  }

  @Get('saved-craftsmen/stats/:craftsmanId')
  getCraftsmenSaveStats(@Param('craftsmanId') craftsmanId: string) {
    return this.analyticsService.getCraftsmenSaveStats(craftsmanId);
  }

  // ========== DASHBOARDS ==========

  @Get('engagement/:userId')
  getUserEngagement(@Param('userId') userId: string) {
    return this.analyticsService.getUserEngagement(userId);
  }

  @Get('platform')
  getPlatformAnalytics() {
    return this.analyticsService.getPlatformAnalytics();
  }
}
