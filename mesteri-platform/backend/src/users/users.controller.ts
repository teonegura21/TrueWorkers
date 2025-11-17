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
import { UsersService } from './users.service';
import { UsersGeoService } from './users-geo.service';
import { User, UserRole } from '@prisma/client';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { FirebaseAuthGuard } from '../guards/firebase-auth.guard';

@Controller('users')
@UseGuards(FirebaseAuthGuard)
export class UsersController {
  constructor(
    private readonly usersService: UsersService,
    private readonly geoService: UsersGeoService,
  ) {}

  @Get()
  findAll() {
    return this.usersService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.usersService.findOne(id);
  }

  @Get('email/:email')
  findByEmail(@Param('email') email: string) {
    return this.usersService.findByEmail(email);
  }

  @Get('role/:role')
  findByRole(@Param('role') role: string) {
    return this.usersService.findByRole(role as UserRole);
  }

  @Post()
  create(@Body() createUserDto: CreateUserDto) {
    return this.usersService.create(createUserDto);
  }

  @Put(':id')
  update(@Param('id') id: string, @Body() updateUserDto: UpdateUserDto) {
    return this.usersService.update(id, updateUserDto);
  }

  @Delete(':id')
  delete(@Param('id') id: string) {
    return this.usersService.delete(id);
  }

  @Get('search')
  search(@Query('q') query: string) {
    return this.usersService.search(query);
  }

  // PHASE 1: Enhanced Craftsman Endpoints
  @Get('craftsmen')
  async getAllCraftsmen(
    @Query('specialty') specialty?: string,
    @Query('isVerified') isVerified?: string,
    @Query('minRating') minRating?: string,
    @Query('city') city?: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    const filters = {
      isVerified: isVerified === 'true' ? true : undefined,
      minRating: minRating ? parseFloat(minRating) : undefined,
      city: city || undefined,
      page: page ? parseInt(page, 10) : 1,
      limit: limit ? parseInt(limit, 10) : 10,
    };
    return this.usersService.getCraftsmenWithSpecialty(specialty, filters);
  }

  @Get('craftsmen/:id')
  async getCraftsmanProfile(@Param('id') id: string) {
    const craftsman = await this.usersService.findOne(id);
    if (craftsman.role !== UserRole.CRAFTSMAN) {
      throw new Error('User is not a craftsman');
    }
    return craftsman;
  }

  @Get('craftsmen/:id/portfolio')
  async getCraftsmanPortfolio(@Param('id') id: string) {
    const craftsman = await this.usersService.findOne(id);
    return {
      craftsmanId: id,
      fullName: craftsman.fullName,
      portfolioPhotos: craftsman.portfolioPhotos || [],
      skillsTags: craftsman.skillsTags || [],
    };
  }

  // GPS-BASED SEARCH ENDPOINTS
  @Get('craftsmen/nearby')
  async searchCraftsmenNearby(
    @Query('lat') lat: string,
    @Query('lng') lng: string,
    @Query('radius') radius?: string,
    @Query('specialty') specialty?: string,
    @Query('minRating') minRating?: string,
    @Query('isVerified') isVerified?: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    const latitude = parseFloat(lat);
    const longitude = parseFloat(lng);

    if (isNaN(latitude) || isNaN(longitude)) {
      throw new Error('Invalid GPS coordinates');
    }

    return this.geoService.searchNearby({
      latitude,
      longitude,
      radiusKm: radius ? parseInt(radius, 10) : 50,
      specialty,
      minRating: minRating ? parseFloat(minRating) : undefined,
      isVerified: isVerified === 'true' ? true : undefined,
      page: page ? parseInt(page, 10) : 1,
      limit: limit ? parseInt(limit, 10) : 20,
    });
  }

  @Put(':id/location')
  async updateUserLocation(
    @Param('id') id: string,
    @Body()
    locationData: {
      latitude: number;
      longitude: number;
      city?: string;
      county?: string;
    },
  ) {
    return this.geoService.updateLocation(
      id,
      locationData.latitude,
      locationData.longitude,
      locationData.city,
      locationData.county,
    );
  }

  @Get('craftsmen/map-bounds')
  async getCraftsmenInBounds(
    @Query('neLat') neLat: string,
    @Query('neLng') neLng: string,
    @Query('swLat') swLat: string,
    @Query('swLng') swLng: string,
  ) {
    return this.geoService.getCraftsmenInBounds(
      { lat: parseFloat(neLat), lng: parseFloat(neLng) },
      { lat: parseFloat(swLat), lng: parseFloat(swLng) },
    );
  }
}
