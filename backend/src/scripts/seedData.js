const mongoose = require('mongoose');
const dotenv = require('dotenv');
const Restaurant = require('../models/Restaurant');
const MenuItem = require('../models/MenuItem');
const User = require('../models/User');
const Order = require('../models/Order');

dotenv.config();

const seedData = async () => {
  try {
    // Connect to database
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB');

    // Clear existing data
    console.log('🗑️  Clearing existing data...');
    await Restaurant.deleteMany({});
    await MenuItem.deleteMany({});
    await Order.deleteMany({});

    // Delete existing test users
    await User.deleteMany({ 
      email: { 
        $in: [
          'admin@foodie.com',
          'owner@foodie.com',
          'shipper1@foodie.com',
          'shipper2@foodie.com',
          'khach1@foodie.com',
          'khach2@foodie.com',
          'khach3@foodie.com'
        ] 
      } 
    });

    // Create admin user
    const admin = await User.create({
      email: 'admin@foodie.com',
      password: 'admin123',
      fullName: 'Admin Quản Trị',
      phone: '0900000001',
      role: 'admin',
      isVerified: true,
      isActive: true,
    });
    console.log('✅ Created admin user');

    // Find or create owner user
    let owner = await User.findOne({ email: 'owner@foodie.com' });
    if (!owner) {
      owner = await User.create({
        email: 'owner@foodie.com',
        password: 'password123',
        fullName: 'Nguyễn Minh Tuấn',
        phone: '0900000002',
        role: 'restaurant_owner',
        isVerified: true,
        isActive: true,
      });
      console.log('✅ Created owner user');
    }

    // Create shipper users
    const shippers = [];
    const shipperData = [
      {
        email: 'shipper1@foodie.com',
        password: 'shipper123',
        fullName: 'Nguyễn Văn A',
        phone: '0901000001',
        role: 'driver',
        isVerified: true,
        isActive: true,
      },
      {
        email: 'shipper2@foodie.com',
        password: 'shipper123',
        fullName: 'Trần Văn B',
        phone: '0901000002',
        role: 'driver',
        isVerified: true,
        isActive: true,
      },
    ];

    for (const data of shipperData) {
      const shipper = await User.create(data);
      shippers.push(shipper);
    }
    console.log(`✅ Created ${shippers.length} shippers`);

    // Create sample customers using User.create() to ensure password hashing
    const customers = [];
    const customerData = [
      {
        email: 'khach1@foodie.com',
        password: 'password123',
        fullName: 'Trần Thị Hương',
        phone: '0901234567',
        role: 'customer',
      },
      {
        email: 'khach2@foodie.com',
        password: 'password123',
        fullName: 'Lê Văn Đức',
        phone: '0902345678',
        role: 'customer',
      },
      {
        email: 'khach3@foodie.com',
        password: 'password123',
        fullName: 'Phạm Thị Mai',
        phone: '0903456789',
        role: 'customer',
      },
    ];

    for (const data of customerData) {
      const customer = await User.create(data);
      customers.push(customer);
    }
    console.log(`✅ Created ${customers.length} customers`);

    // Restaurant data with images and menu items with images
    const restaurantData = [
      {
        name: 'Phở Hương Nam',
        description: 'Phở bò, phở gà truyền thống Hà Nội',
        address: '45 Nguyễn Du, Quận 1, TP.HCM',
        latitude: 10.7769,
        longitude: 106.7009,
        phone: '02838291234',
        email: 'phohuongnam@foodie.com',
        logoUrl: 'https://images.unsplash.com/photo-1529042410759-befb1d7480a5?w=200&h=200&fit=crop',
        coverImageUrl: 'https://images.unsplash.com/photo-1529042410759-befb1d7480a5?w=800&h=400&fit=crop',
        deliveryFee: 15000,
        minimumOrder: 50000,
        ratingAverage: 4.6,
        ratingCount: 234,
        cuisine: 'Vietnamese',
        menuItems: [
          { name: 'Phở Bò Tái', description: 'Phở bò tái chín, nước dùng đậm đà', price: 75000, isPopular: true, imageUrl: 'https://images.unsplash.com/photo-1529042410759-befb1d7480a5?w=400&h=300&fit=crop' },
          { name: 'Phở Bò Chín', description: 'Phở bò chín mềm, thơm ngon', price: 70000, isPopular: true, imageUrl: 'https://images.unsplash.com/photo-1529042410759-befb1d7480a5?w=400&h=300&fit=crop' },
          { name: 'Phở Gà', description: 'Phở gà ta, nước trong thanh', price: 65000, isPopular: false, imageUrl: 'https://images.unsplash.com/photo-1529042410759-befb1d7480a5?w=400&h=300&fit=crop' },
          { name: 'Bánh Cuốn', description: 'Bánh cuốn nóng, nhân thịt', price: 55000, isPopular: false, imageUrl: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400&h=300&fit=crop' },
        ],
      },
      {
        name: 'Sushi Tokyo',
        description: 'Sushi, sashimi Nhật Bản tươi ngon',
        address: '123 Lê Lợi, Quận 1, TP.HCM',
        latitude: 10.7756,
        longitude: 106.7019,
        phone: '02838234567',
        email: 'sushitokyo@foodie.com',
        logoUrl: 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=200&h=200&fit=crop',
        coverImageUrl: 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=800&h=400&fit=crop',
        deliveryFee: 25000,
        minimumOrder: 150000,
        ratingAverage: 4.8,
        ratingCount: 189,
        cuisine: 'Japanese',
        menuItems: [
          { name: 'Sushi Set 10 miếng', description: 'Set sushi đa dạng, tươi ngon', price: 250000, isPopular: true, imageUrl: 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=400&h=300&fit=crop' },
          { name: 'Sashimi Cá Hồi', description: 'Cá hồi tươi, cắt dày', price: 180000, isPopular: true, imageUrl: 'https://images.unsplash.com/photo-1611143669185-af224c5e3252?w=400&h=300&fit=crop' },
          { name: 'Maki California', description: 'Cuốn California với bơ và cua', price: 120000, isPopular: true, imageUrl: 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=400&h=300&fit=crop' },
          { name: 'Tempura Tôm', description: 'Tôm tempura giòn, nóng hổi', price: 140000, isPopular: false, imageUrl: 'https://images.unsplash.com/photo-1626700051175-6818013e1d4f?w=400&h=300&fit=crop' },
          { name: 'Ramen Tonkotsu', description: 'Ramen nước dùng xương heo đậm đà', price: 160000, isPopular: false, imageUrl: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400&h=300&fit=crop' },
        ],
      },
      {
        name: 'KFC Việt Nam',
        description: 'Gà rán KFC thương hiệu Mỹ',
        address: '78 Nguyễn Huệ, Quận 1, TP.HCM',
        latitude: 10.7736,
        longitude: 106.7033,
        phone: '02838245678',
        email: 'kfc@foodie.com',
        logoUrl: 'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=200&h=200&fit=crop',
        coverImageUrl: 'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=800&h=400&fit=crop',
        deliveryFee: 20000,
        minimumOrder: 80000,
        ratingAverage: 4.3,
        ratingCount: 567,
        cuisine: 'American',
        menuItems: [
          { name: 'Gà Rán 2 Miếng', description: '2 miếng gà rán giòn, nóng', price: 89000, isPopular: true, imageUrl: 'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=400&h=300&fit=crop' },
          { name: 'Combo Gà Rán', description: 'Gà rán + khoai tây + pepsi', price: 129000, isPopular: true, imageUrl: 'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=400&h=300&fit=crop' },
          { name: 'Burger Zinger', description: 'Burger gà cay, phô mai', price: 99000, isPopular: true, imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&h=300&fit=crop' },
          { name: 'Khoai Tây Chiên', description: 'Khoai tây chiên giòn, nóng', price: 45000, isPopular: false, imageUrl: 'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=400&h=300&fit=crop' },
        ],
      },
      {
        name: 'Bún Chả Hà Nội',
        description: 'Bún chả Hà Nội chính hiệu',
        address: '12 Trần Hưng Đạo, Quận 5, TP.HCM',
        latitude: 10.7544,
        longitude: 106.6694,
        phone: '02838351234',
        email: 'buncha@foodie.com',
        logoUrl: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=200&h=200&fit=crop',
        coverImageUrl: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=800&h=400&fit=crop',
        deliveryFee: 12000,
        minimumOrder: 40000,
        ratingAverage: 4.7,
        ratingCount: 312,
        cuisine: 'Vietnamese',
        menuItems: [
          { name: 'Bún Chả Thịt Nướng', description: 'Bún chả thịt nướng than hoa', price: 65000, isPopular: true, imageUrl: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=400&h=300&fit=crop' },
          { name: 'Bún Chả Nem', description: 'Bún chả kèm nem rán', price: 75000, isPopular: true, imageUrl: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=400&h=300&fit=crop' },
          { name: 'Bún Chả Đặc Biệt', description: 'Bún chả đầy đủ, thịt nhiều', price: 85000, isPopular: false, imageUrl: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=400&h=300&fit=crop' },
        ],
      },
      {
        name: 'Pizza 4P\'s',
        description: 'Pizza Ý cao cấp, phô mai sữa tươi',
        address: '151 Đồng Khởi, Quận 1, TP.HCM',
        latitude: 10.7764,
        longitude: 106.7010,
        phone: '02838267890',
        email: 'pizza4ps@foodie.com',
        logoUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=200&h=200&fit=crop',
        coverImageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=800&h=400&fit=crop',
        deliveryFee: 30000,
        minimumOrder: 200000,
        ratingAverage: 4.9,
        ratingCount: 445,
        cuisine: 'Italian',
        menuItems: [
          { name: 'Pizza Margherita', description: 'Pizza cổ điển phô mai mozzarella', price: 220000, isPopular: true, imageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400&h=300&fit=crop' },
          { name: 'Pizza 4 Cheese', description: 'Pizza 4 loại phô mai', price: 280000, isPopular: true, imageUrl: 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=400&h=300&fit=crop' },
          { name: 'Pizza Prosciutto', description: 'Pizza với giăm bông Ý', price: 320000, isPopular: true, imageUrl: 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=400&h=300&fit=crop' },
          { name: 'Pasta Carbonara', description: 'Pasta kem, thịt xông khói', price: 180000, isPopular: false, imageUrl: 'https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=400&h=300&fit=crop' },
        ],
      },
      {
        name: 'Gogi House',
        description: 'Nướng Hàn Quốc, thịt nướng BBQ',
        address: '89 Nguyễn Thị Minh Khai, Quận 3, TP.HCM',
        latitude: 10.7908,
        longitude: 106.6934,
        phone: '02838345678',
        email: 'gogihouse@foodie.com',
        logoUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?w=200&h=200&fit=crop',
        coverImageUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?w=800&h=400&fit=crop',
        deliveryFee: 25000,
        minimumOrder: 120000,
        ratingAverage: 4.5,
        ratingCount: 278,
        cuisine: 'Korean',
        menuItems: [
          { name: 'Set Thịt Ba Chỉ Nướng', description: 'Set thịt ba chỉ + rau sống', price: 199000, isPopular: true, imageUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?w=400&h=300&fit=crop' },
          { name: 'Set Thịt Bò Nướng', description: 'Set thịt bò Mỹ nướng', price: 299000, isPopular: true, imageUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?w=400&h=300&fit=crop' },
          { name: 'Kimchi Jjigae', description: 'Canh kimchi cay nóng', price: 120000, isPopular: false, imageUrl: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400&h=300&fit=crop' },
          { name: 'Bibimbap', description: 'Cơm trộn Hàn Quốc', price: 150000, isPopular: false, imageUrl: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=400&h=300&fit=crop' },
        ],
      },
      {
        name: 'Dimsum Đông Phương',
        description: 'Dimsum, món Trung Hoa',
        address: '234 Võ Văn Tần, Quận 3, TP.HCM',
        latitude: 10.7870,
        longitude: 106.6904,
        phone: '02838356789',
        email: 'dimsum@foodie.com',
        logoUrl: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=200&h=200&fit=crop',
        coverImageUrl: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=800&h=400&fit=crop',
        deliveryFee: 18000,
        minimumOrder: 80000,
        ratingAverage: 4.4,
        ratingCount: 201,
        cuisine: 'Chinese',
        menuItems: [
          { name: 'Sủi Cảo Tôm', description: 'Sủi cảo tôm tươi, 6 cái', price: 95000, isPopular: true, imageUrl: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400&h=300&fit=crop' },
          { name: 'Bánh Bao Nhân Thịt', description: 'Bánh bao hấp, nhân thịt', price: 45000, isPopular: true, imageUrl: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400&h=300&fit=crop' },
          { name: 'Xíu Mại', description: 'Xíu mại hấp, 4 cái', price: 75000, isPopular: true, imageUrl: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400&h=300&fit=crop' },
          { name: 'Chả Giò Tôm', description: 'Chả giò tôm, 4 cái', price: 85000, isPopular: false, imageUrl: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400&h=300&fit=crop' },
        ],
      },
      {
        name: 'Cơm Tấm Sài Gòn',
        description: 'Cơm tấm sườn nướng đặc sản Sài Gòn',
        address: '56 Lý Tự Trọng, Quận 1, TP.HCM',
        latitude: 10.7744,
        longitude: 106.7024,
        phone: '02838278901',
        email: 'comtam@foodie.com',
        logoUrl: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=200&h=200&fit=crop',
        coverImageUrl: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=800&h=400&fit=crop',
        deliveryFee: 10000,
        minimumOrder: 35000,
        ratingAverage: 4.6,
        ratingCount: 456,
        cuisine: 'Vietnamese',
        menuItems: [
          { name: 'Cơm Tấm Sườn Nướng', description: 'Cơm tấm sườn nướng, bì, chả', price: 65000, isPopular: true, imageUrl: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=400&h=300&fit=crop' },
          { name: 'Cơm Tấm Sườn Bì Chả', description: 'Đầy đủ sườn, bì, chả trứng', price: 75000, isPopular: true, imageUrl: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=400&h=300&fit=crop' },
          { name: 'Cơm Tấm Đùi Gà', description: 'Cơm tấm đùi gà nướng', price: 70000, isPopular: false, imageUrl: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=400&h=300&fit=crop' },
        ],
      },
      {
        name: 'Burger King',
        description: 'Burger và khoai tây chiên',
        address: '90 Nguyễn Huệ, Quận 1, TP.HCM',
        latitude: 10.7733,
        longitude: 106.7031,
        phone: '02838289012',
        email: 'burgerking@foodie.com',
        logoUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=200&h=200&fit=crop',
        coverImageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=800&h=400&fit=crop',
        deliveryFee: 20000,
        minimumOrder: 70000,
        ratingAverage: 4.2,
        ratingCount: 389,
        cuisine: 'American',
        menuItems: [
          { name: 'Whopper Burger', description: 'Burger thịt bò nướng lớn', price: 119000, isPopular: true, imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&h=300&fit=crop' },
          { name: 'Chicken Burger', description: 'Burger gà giòn', price: 99000, isPopular: true, imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&h=300&fit=crop' },
          { name: 'Combo Whopper', description: 'Whopper + khoai + pepsi', price: 149000, isPopular: true, imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&h=300&fit=crop' },
        ],
      },
      {
        name: 'Bánh Mì Huỳnh Hoa',
        description: 'Bánh mì thịt nguội nổi tiếng Sài Gòn',
        address: '26 Lê Thị Riêng, Quận 1, TP.HCM',
        latitude: 10.7719,
        longitude: 106.6984,
        phone: '02838290123',
        email: 'banhmi@foodie.com',
        logoUrl: 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=200&h=200&fit=crop',
        coverImageUrl: 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=800&h=400&fit=crop',
        deliveryFee: 8000,
        minimumOrder: 30000,
        ratingAverage: 4.8,
        ratingCount: 678,
        cuisine: 'Vietnamese',
        menuItems: [
          { name: 'Bánh Mì Thịt Nguội', description: 'Bánh mì thịt nguội đặc biệt', price: 45000, isPopular: true, imageUrl: 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=400&h=300&fit=crop' },
          { name: 'Bánh Mì Chả Cá', description: 'Bánh mì chả cá viên', price: 40000, isPopular: true, imageUrl: 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=400&h=300&fit=crop' },
          { name: 'Bánh Mì Pate', description: 'Bánh mì pate truyền thống', price: 35000, isPopular: false, imageUrl: 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=400&h=300&fit=crop' },
        ],
      },
      {
        name: 'Thái Express',
        description: 'Món Thái Lan chua cay',
        address: '145 Pasteur, Quận 3, TP.HCM',
        latitude: 10.7888,
        longitude: 106.6912,
        phone: '02838301234',
        email: 'thaiexpress@foodie.com',
        logoUrl: 'https://images.unsplash.com/photo-1552568877-0c0c0c0c0c0c?w=200&h=200&fit=crop',
        coverImageUrl: 'https://images.unsplash.com/photo-1552568877-0c0c0c0c0c0c?w=800&h=400&fit=crop',
        deliveryFee: 20000,
        minimumOrder: 90000,
        ratingAverage: 4.5,
        ratingCount: 234,
        cuisine: 'Thai',
        menuItems: [
          { name: 'Pad Thai', description: 'Mì xào Thái, tôm, đậu phộng', price: 120000, isPopular: true, imageUrl: 'https://images.unsplash.com/photo-1552568877-0c0c0c0c0c0c?w=400&h=300&fit=crop' },
          { name: 'Tom Yum Goong', description: 'Canh chua tôm Thái', price: 150000, isPopular: true, imageUrl: 'https://images.unsplash.com/photo-1552568877-0c0c0c0c0c0c?w=400&h=300&fit=crop' },
          { name: 'Green Curry', description: 'Cà ri xanh Thái, gà', price: 140000, isPopular: false, imageUrl: 'https://images.unsplash.com/photo-1552568877-0c0c0c0c0c0c?w=400&h=300&fit=crop' },
          { name: 'Mango Sticky Rice', description: 'Xôi xoài Thái', price: 80000, isPopular: false, imageUrl: 'https://images.unsplash.com/photo-1552568877-0c0c0c0c0c0c?w=400&h=300&fit=crop' },
        ],
      },
      {
        name: 'Bún Bò Huế Cô Ba',
        description: 'Bún bò Huế cay nồng đặc sản',
        address: '78 Điện Biên Phủ, Quận Bình Thạnh, TP.HCM',
        latitude: 10.8019,
        longitude: 106.7148,
        phone: '02838412345',
        email: 'bunbohue@foodie.com',
        logoUrl: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=200&h=200&fit=crop',
        coverImageUrl: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=800&h=400&fit=crop',
        deliveryFee: 15000,
        minimumOrder: 45000,
        ratingAverage: 4.7,
        ratingCount: 345,
        cuisine: 'Vietnamese',
        menuItems: [
          { name: 'Bún Bò Huế Đặc Biệt', description: 'Bún bò đầy đủ, thịt bò, giò', price: 75000, isPopular: true, imageUrl: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400&h=300&fit=crop' },
          { name: 'Bún Bò Huế Thường', description: 'Bún bò cơ bản', price: 60000, isPopular: true, imageUrl: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400&h=300&fit=crop' },
          { name: 'Bún Bò Huế Chả Cá', description: 'Bún bò kèm chả cá', price: 80000, isPopular: false, imageUrl: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400&h=300&fit=crop' },
        ],
      },
      {
        name: 'Sashimi Premium',
        description: 'Sashimi cao cấp, tươi sống',
        address: '201 Nguyễn Văn Cừ, Quận 5, TP.HCM',
        latitude: 10.7556,
        longitude: 106.6678,
        phone: '02838423456',
        email: 'sashimi@foodie.com',
        logoUrl: 'https://images.unsplash.com/photo-1611143669185-af224c5e3252?w=200&h=200&fit=crop',
        coverImageUrl: 'https://images.unsplash.com/photo-1611143669185-af224c5e3252?w=800&h=400&fit=crop',
        deliveryFee: 30000,
        minimumOrder: 180000,
        ratingAverage: 4.9,
        ratingCount: 156,
        cuisine: 'Japanese',
        menuItems: [
          { name: 'Sashimi Set Premium', description: 'Set sashimi đa dạng cao cấp', price: 350000, isPopular: true, imageUrl: 'https://images.unsplash.com/photo-1611143669185-af224c5e3252?w=400&h=300&fit=crop' },
          { name: 'Sashimi Cá Ngừ', description: 'Cá ngừ tươi, cắt dày', price: 220000, isPopular: true, imageUrl: 'https://images.unsplash.com/photo-1611143669185-af224c5e3252?w=400&h=300&fit=crop' },
          { name: 'Sashimi Tôm', description: 'Tôm sống tươi ngon', price: 180000, isPopular: false, imageUrl: 'https://images.unsplash.com/photo-1611143669185-af224c5e3252?w=400&h=300&fit=crop' },
        ],
      },
      {
        name: 'Cháo Lòng Cô Út',
        description: 'Cháo lòng, cháo gà đặc sản',
        address: '34 Nguyễn Thị Minh Khai, Quận 3, TP.HCM',
        latitude: 10.7895,
        longitude: 106.6921,
        phone: '02838434567',
        email: 'chaolong@foodie.com',
        logoUrl: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=200&h=200&fit=crop',
        coverImageUrl: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=800&h=400&fit=crop',
        deliveryFee: 10000,
        minimumOrder: 40000,
        ratingAverage: 4.4,
        ratingCount: 289,
        cuisine: 'Vietnamese',
        menuItems: [
          { name: 'Cháo Lòng Đặc Biệt', description: 'Cháo lòng đầy đủ nội tạng', price: 65000, isPopular: true, imageUrl: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400&h=300&fit=crop' },
          { name: 'Cháo Gà Ta', description: 'Cháo gà ta thơm ngon', price: 60000, isPopular: true, imageUrl: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400&h=300&fit=crop' },
          { name: 'Cháo Vịt', description: 'Cháo vịt đậm đà', price: 70000, isPopular: false, imageUrl: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400&h=300&fit=crop' },
        ],
      },
      {
        name: 'BBQ House',
        description: 'Nướng BBQ, thịt nướng đa dạng',
        address: '167 Lý Tự Trọng, Quận 1, TP.HCM',
        latitude: 10.7748,
        longitude: 106.7028,
        phone: '02838445678',
        email: 'bbqhouse@foodie.com',
        logoUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?w=200&h=200&fit=crop',
        coverImageUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?w=800&h=400&fit=crop',
        deliveryFee: 22000,
        minimumOrder: 100000,
        ratingAverage: 4.6,
        ratingCount: 267,
        cuisine: 'BBQ',
        menuItems: [
          { name: 'Set Sườn Nướng', description: 'Set sườn heo nướng + rau', price: 180000, isPopular: true, imageUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?w=400&h=300&fit=crop' },
          { name: 'Set Thịt Bò Nướng', description: 'Set thịt bò Mỹ nướng', price: 250000, isPopular: true, imageUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?w=400&h=300&fit=crop' },
          { name: 'Set Gà Nướng', description: 'Set gà nướng mật ong', price: 150000, isPopular: false, imageUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?w=400&h=300&fit=crop' },
        ],
      },
    ];

    // Create restaurants
    console.log('🍽️  Creating restaurants...');
    const restaurants = [];
    for (const data of restaurantData) {
      const restaurant = await Restaurant.create({
        ...data,
        ownerId: owner._id,
      });
      restaurants.push(restaurant);
    }
    console.log(`✅ Created ${restaurants.length} restaurants`);

    // Create menu items for each restaurant and store them
    console.log('📋 Creating menu items...');
    const allMenuItems = []; // Store all menu items by restaurant
    let totalMenuItems = 0;
    for (let i = 0; i < restaurants.length; i++) {
      const restaurant = restaurants[i];
      const menuData = restaurantData[i].menuItems.map(item => ({
        ...item,
        restaurantId: restaurant._id,
      }));
      const menuItems = await MenuItem.insertMany(menuData);
      allMenuItems[restaurant._id.toString()] = menuItems; // Store by restaurant ID
      totalMenuItems += menuItems.length;
    }
    console.log(`✅ Created ${totalMenuItems} menu items`);

    // Create 30 sample orders with valid menu items
    console.log('📦 Creating 30 sample orders...');
    const orders = [];
    const orderStatuses = ['pending', 'confirmed', 'preparing', 'ready', 'picked_up', 'on_the_way', 'delivered', 'cancelled'];
    const paymentMethods = ['cash', 'card', 'momo', 'zalopay'];
    const paymentStatuses = ['pending', 'paid', 'failed'];
    const addresses = [
      '123 Nguyễn Trãi, Quận 5, TP.HCM',
      '456 Lê Văn Việt, Quận 9, TP.HCM',
      '789 Võ Văn Tần, Quận 3, TP.HCM',
      '321 Nguyễn Đình Chiểu, Quận 3, TP.HCM',
      '654 Trần Hưng Đạo, Quận 5, TP.HCM',
      '147 Pasteur, Quận 3, TP.HCM',
      '258 Điện Biên Phủ, Quận Bình Thạnh, TP.HCM',
      '369 Lý Tự Trọng, Quận 1, TP.HCM',
      '741 Nguyễn Huệ, Quận 1, TP.HCM',
      '852 Lê Lợi, Quận 1, TP.HCM',
    ];

    // Create 30 orders
    for (let i = 0; i < 30; i++) {
      // Random restaurant
      const restaurant = restaurants[Math.floor(Math.random() * restaurants.length)];
      const restaurantMenuItems = allMenuItems[restaurant._id.toString()];
      
      if (!restaurantMenuItems || restaurantMenuItems.length === 0) {
        continue;
      }

      // Random customer
      const customer = customers[Math.floor(Math.random() * customers.length)];
      
      // Random 1-3 menu items
      const numItems = Math.floor(Math.random() * 3) + 1;
      const selectedItems = [];
      const usedIndices = new Set();
      
      for (let j = 0; j < numItems && j < restaurantMenuItems.length; j++) {
        let itemIndex;
        do {
          itemIndex = Math.floor(Math.random() * restaurantMenuItems.length);
        } while (usedIndices.has(itemIndex));
        usedIndices.add(itemIndex);
        selectedItems.push(restaurantMenuItems[itemIndex]);
      }

      // Calculate totals
      const subtotal = selectedItems.reduce((sum, item) => {
        const quantity = Math.floor(Math.random() * 3) + 1;
        return sum + (item.price * quantity);
      }, 0);
      const deliveryFee = restaurant.deliveryFee;
      const totalAmount = subtotal + deliveryFee;

      // Random status (more delivered orders)
      let status;
      if (i < 15) {
        status = 'delivered';
      } else if (i < 20) {
        status = 'on_the_way';
      } else if (i < 25) {
        status = 'preparing';
      } else {
        status = orderStatuses[Math.floor(Math.random() * orderStatuses.length)];
      }

      // Random payment
      const paymentMethod = paymentMethods[Math.floor(Math.random() * paymentMethods.length)];
      const paymentStatus = status === 'delivered' ? 'paid' : 
                           (status === 'cancelled' ? 'failed' : 
                           paymentStatuses[Math.floor(Math.random() * paymentStatuses.length)]);

      // Create order items
      const orderItems = selectedItems.map(item => {
        const quantity = Math.floor(Math.random() * 3) + 1;
        return {
          menuItemId: item._id,
          quantity: quantity,
          unitPrice: item.price,
          subtotal: item.price * quantity,
        };
      });

      // Random date (some in past, some recent)
      const daysAgo = i < 20 ? Math.floor(Math.random() * 30) : 0;
      const createdAt = new Date(Date.now() - daysAgo * 24 * 60 * 60 * 1000);
      const deliveredAt = status === 'delivered' ? new Date(createdAt.getTime() + 30 * 60 * 1000) : null;

      const order = await Order.create({
        orderNumber: `ORD${Date.now()}${String(i + 1).padStart(3, '0')}`,
        customerId: customer._id,
        restaurantId: restaurant._id,
        status: status,
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        totalAmount: totalAmount,
        paymentMethod: paymentMethod,
        paymentStatus: paymentStatus,
        deliveryAddress: addresses[Math.floor(Math.random() * addresses.length)],
        items: orderItems,
        createdAt: createdAt,
        deliveredAt: deliveredAt,
      });

      orders.push(order);
    }

    console.log(`✅ Created ${orders.length} sample orders`);

    // Print summary
    console.log('\n📊 Data Summary:');
    console.log(`- Restaurants: ${restaurants.length}`);
    console.log(`- Menu Items: ${totalMenuItems}`);
    console.log(`- Customers: ${customers.length}`);
    console.log(`- Orders: ${orders.length}`);
    
    console.log('\n🍽️  Restaurants:');
    restaurants.forEach((r, i) => {
      console.log(`  ${i + 1}. ${r.name} (${restaurantData[i].cuisine}) - ID: ${r._id}`);
    });

    console.log('\n✅ Seed data created successfully!');
    console.log('\n💡 You can now test the app with real data!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error seeding data:', error);
    process.exit(1);
  }
};

seedData();
