import 'package:flutter/material.dart';
import 'package:goodie/main.dart';

import '../model/review.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final List<ReviewPost> reviewPosts = [
    ReviewPost(
      restaurantName: 'Villa Paradiso',
      location: 'Oslo, Norway',
      cuisineType: 'Pizza',
      website: 'www.villaparadiso.com',
      username: 'JohnDoe',
      profilePicture:
          'https://yt3.googleusercontent.com/ytc/AOPolaRGBOhr78O2loRlE8jQg-23Q7uWRFJg19nkQIwQ1g=s176-c-k-c0x00ffffff-no-rj',
      reviewDate: DateTime.now(),
      rating: 8.2,
      reviewText: 'Amazing pizza! Loved the ambiance.',
      images: [
        'https://imageproxy.wolt.com/venue/6331824ac3bf3316927805a6/2eb0bbd0-3efd-11ed-ae0c-fa0c5ab157a5_9505b738_027a_11ed_a7f4_ae90632c0785_villa_paradiso_grunerlokka4914_2.jpg',
        'https://imageproxy.wolt.com/menu/menu-images/62c690d34c4bf4c63e46d0ad/1b68d582-0279-11ed-b41d-3ef3a7357024_quatro_formaggiii.jpeg',
        'https://imageproxy.wolt.com/menu/menu-images/62c690d34c4bf4c63e46d0ad/e42d2cfc-0279-11ed-a23b-721faa187e49_villa_paradiso_grunerlokka4858.jpeg'
      ],
      visitDate: DateTime(2023, 07, 30),
      priceRange: '\$\$',
      likes: 103,
      comments: ['Great review!', 'I want to try this place!'],
      recommendations: true,
      tags: ['Family Friendly'],
      specialOffers: 'Happy Hour: 4-6 PM',
    ),
    // Repeat similar structure for other restaurants
    ReviewPost(
      restaurantName: 'Cafe Laundromat',
      location: 'Oslo, Norway',
      cuisineType: 'Burgers and Sandwiches',
      website: 'www.cafelaundromat.com',
      username: 'MBW',
      profilePicture:
          'https://i.pinimg.com/280x280_RS/c7/74/0b/c7740b01eeb376819d1977e7dfe575ad.jpg',
      reviewDate: DateTime.now(),
      rating: 8.8,
      reviewText: 'Delicious burgers!',
      images: [
        'https://imageproxy.wolt.com/venue/6176b62b1e6cbc23e4b60960/d949fd74-37fe-11ec-938b-2e6beda10341_cafe__laundromat1787.jpg',
        'https://imageproxy.wolt.com/menu/menu-images/6178fe0f9fc329cc951ba4f8/7250292a-38aa-11ec-88c4-d2df64f54252_0sweet_potato_fries.jpeg',
        'https://imageproxy.wolt.com/menu/menu-images/6178fe0f9fc329cc951ba4f8/b4dea2e2-e7d9-11ec-a4c0-3256273d114e_cafe_laundromat1153.jpeg'
      ],
      visitDate: DateTime(2023, 07, 28),
      priceRange: '\$\$',
      likes: 56,
      comments: [],
      recommendations: true,
      tags: ['Casual Dining'],
      specialOffers: '',
    ),
    ReviewPost(
      restaurantName: 'Lett',
      location: 'Oslo, Norway',
      cuisineType: 'Salads',
      website: 'www.lett.com',
      username: 'HealthyEater',
      profilePicture:
          'https://yt3.googleusercontent.com/ytc/AOPolaQfWAT8ULTawCxZI-zROhmZOqfS1xMTsF-2_Sjs=s176-c-k-c0x00ffffff-no-rj',
      reviewDate: DateTime.now(),
      rating: 7.9,
      reviewText: 'Fresh and healthy salads. Highly recommended!',
      images: [
        'https://imageproxy.wolt.com/venue/61e034270d61c8b36cbf0546/42f7dd50-a224-11ed-bb1b-4ecd7d6d0773_green_.png',
        'https://imageproxy.wolt.com/menu/menu-images/61e035264ea5e663596a64ce/66bac2ac-a20b-11ed-8265-e209bdadf482_spicy_kylling_wrap.jpeg',
        'https://imageproxy.wolt.com/menu/menu-images/61e035264ea5e663596a64ce/ea687866-a20a-11ed-9ae2-e209bdadf482_meksikansk_bowl.jpeg'
      ],
      visitDate: DateTime(2023, 07, 15),
      priceRange: '\$',
      likes: 75,
      comments: ['Yummy!', 'Looks fresh!'],
      recommendations: true,
      tags: ['Healthy Options'],
      specialOffers: '',
    ),
    ReviewPost(
      restaurantName: 'El Camino',
      location: 'Oslo, Norway',
      cuisineType: 'Mexican',
      website: 'www.elcamino.com',
      username: 'SpicyLover',
      profilePicture:
          'https://yt3.googleusercontent.com/ytc/AOPolaRkkzpvS4ZUVjXHHwfqNs91theJwBaPbN83UagiQw=s176-c-k-c0x00ffffff-no-rj',
      reviewDate: DateTime.now(),
      rating: 3.8,
      reviewText: 'Tasty burritos, but a bit too spicy for me.',
      images: [
        'https://imageproxy.wolt.com/venue/5ff855f80c384aac1a506d9d/06f11482-6231-11eb-b650-a62efa445559_el_camino3286.jpg',
        'https://imageproxy.wolt.com/menu/menu-images/600834917c370057f858492d/d15d38e6-619f-11eb-a4f4-a2d1f957fc68_beef.jpeg',
        'https://imageproxy.wolt.com/menu/menu-images/600834917c370057f858492d/093a3482-6207-11eb-8296-329399c3d75e_chips.jpeg'
      ],
      visitDate: DateTime(2023, 07, 10),
      priceRange: '\$\$',
      likes: 48,
      comments: ['Spice is nice!'],
      recommendations: true,
      tags: ['Spicy Food'],
      specialOffers: '2-for-1 on Tuesdays',
    ),
    ReviewPost(
      restaurantName: 'Kverneriet Solli Plass',
      location: 'Oslo, Norway',
      cuisineType: 'Burgers',
      website: 'www.kverneriet.com',
      username: 'BurgerFan',
      profilePicture:
          'https://yt3.googleusercontent.com/OrRUxv5-jCFQMrIpDDY5Q5ugQzM4VwEGYBzbh_tik2TUUN5ViyuT-8rUjV7X-cNhFcjnv6vhaQ=s176-c-k-c0x00ffffff-no-rj',
      reviewDate: DateTime.now(),
      rating: 8.4,
      reviewText: 'The best high-end burgers in town!',
      images: [
        'https://imageproxy.wolt.com/venue/600ffcc307a426fc872381c2/0730d81e-618d-11eb-9d19-6abb41ef4f69_img_0462.jpg',
        'https://imageproxy.wolt.com/menu/menu-images/601177abd6a5887d58b4596b/3064f144-9971-11ec-9ae5-9e7d3f6bacff_true_blue.jpeg',
        'https://imageproxy.wolt.com/menu/menu-images/601177abd6a5887d58b4596b/dd5f9e04-4e10-11ed-8e5f-eecd120cf66c_7caf222a_c9ed_11ec_890f_de3e21aa8f7f_hot_chick.jpeg'
      ],
      visitDate: DateTime(2023, 07, 5),
      priceRange: '\$\$\$',
      likes: 120,
      comments: ['I agree, simply the best!', 'Must try!'],
      recommendations: true,
      tags: ['Gourmet Burgers'],
      specialOffers: '',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.pink[300],
        title: const Text(
          'Goodie',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        elevation: 8,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
            itemCount: reviewPosts.length,
            itemBuilder: (context, index) {
              // if (index > 1) {
              //   return Container();
              // }

              final post = reviewPosts[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile Picture and User Info
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundImage:
                                  NetworkImage(post.profilePicture),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              post.username,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Restaurant Images - Horizontal Scrollable
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: post.images.length,
                            itemBuilder: (context, index) => Padding(
                              padding: EdgeInsets.only(
                                  right:
                                      index < post.images.length - 1 ? 8.0 : 0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.network(
                                  post.images[index],
                                  fit: BoxFit.cover,
                                  height: 200,
                                  width: 200,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Restaurant Name and Rating
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              post.restaurantName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              '${post.rating}/10',
                              style: const TextStyle(
                                  color: accent1Color,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),

                        // Cuisine Type and Price Range
                        Text(
                          '${post.cuisineType} • ${post.priceRange}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 10),

                        // Review Text
                        Text(
                          post.reviewText,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 16),
                        ),

                        // Actions like Like and Comment
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.thumb_up, color: Colors.grey[600]),
                                const SizedBox(width: 5),
                                Text('${post.likes} Likes'),
                              ],
                            ),
                            Text('${post.comments.length} Comments'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
      ),
    );
  }
}
