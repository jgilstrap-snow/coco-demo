-- Product FAQs and Cortex Search Service
-- Enables RAG (Retrieval Augmented Generation) for the agent

-- Create FAQs table
CREATE OR REPLACE TABLE JACK.DEMO.PRODUCT_FAQS (
    faq_id INT,
    product_id INT,
    category VARCHAR(50),
    question VARCHAR(500),
    answer VARCHAR(2000)
);

-- Insert product FAQs
INSERT INTO JACK.DEMO.PRODUCT_FAQS VALUES
(1, 101, 'Electronics', 'What is the battery life of the Wireless Headphones?', 'The Wireless Headphones provide up to 30 hours of playback on a single charge. Quick charge gives 3 hours of playback from just 10 minutes of charging.'),
(2, 101, 'Electronics', 'Are the Wireless Headphones noise canceling?', 'Yes, the Wireless Headphones feature active noise cancellation (ANC) technology that reduces ambient noise by up to 90%.'),
(3, 102, 'Electronics', 'Is the Smart Watch waterproof?', 'The Smart Watch has a water resistance rating of 5ATM, meaning it can be worn while swimming in shallow water. However, it should not be used for diving or high-pressure water activities.'),
(4, 102, 'Electronics', 'What health features does the Smart Watch have?', 'The Smart Watch includes heart rate monitoring, blood oxygen (SpO2) tracking, sleep analysis, stress monitoring, and workout detection for over 100 exercise types.'),
(5, 103, 'Apparel', 'What sizes are available for Running Shoes?', 'Running Shoes are available in US sizes 6-14 for men and 5-12 for women, including half sizes. Wide width options are available for select sizes.'),
(6, 103, 'Apparel', 'How do I care for my Running Shoes?', 'Remove insoles and laces, hand wash with mild soap and cold water. Air dry away from direct heat. Do not machine wash or put in dryer.'),
(7, 104, 'Fitness', 'What is the Yoga Mat made of?', 'The Yoga Mat is made from eco-friendly TPE (thermoplastic elastomer) material. It is free from PVC, latex, and toxic chemicals. The mat is 6mm thick for optimal cushioning.'),
(8, 104, 'Fitness', 'How do I clean the Yoga Mat?', 'Wipe down with a damp cloth after each use. For deep cleaning, mix water with mild soap, wipe the mat, and air dry completely before rolling.'),
(9, 105, 'Home', 'What brewing methods does the Coffee Maker support?', 'The Coffee Maker supports drip brewing with programmable settings. It can brew 1-12 cups and includes options for bold brew, regular strength, and iced coffee.'),
(10, 105, 'Home', 'Does the Coffee Maker have a warranty?', 'Yes, the Coffee Maker comes with a 2-year manufacturer warranty covering defects in materials and workmanship. Extended warranties are available for purchase.'),
(11, 106, 'Accessories', 'What is the capacity of the Backpack?', 'The Backpack has a 30L capacity with a dedicated 15.6" laptop compartment, multiple organizer pockets, and a hidden anti-theft pocket.'),
(12, 107, 'Electronics', 'Is the Bluetooth Speaker portable?', 'Yes, the Bluetooth Speaker is fully portable with a built-in rechargeable battery lasting up to 12 hours. It weighs only 1.2 lbs and includes a carrying strap.'),
(13, 108, 'Fitness', 'Is the Water Bottle dishwasher safe?', 'Yes, the Water Bottle is top-rack dishwasher safe. It is made from BPA-free Tritan plastic and keeps drinks cold for up to 24 hours with the insulated version.'),
(14, 109, 'Home', 'What light settings does the Desk Lamp have?', 'The Desk Lamp offers 5 brightness levels and 3 color temperatures (warm, neutral, cool). It includes a USB charging port and touch controls.'),
(15, 110, 'Accessories', 'Are the Sunglasses polarized?', 'Yes, the Sunglasses feature polarized lenses that reduce glare by 99% and provide 100% UV protection. Lenses are scratch-resistant with anti-reflective coating.');

-- Store policies
INSERT INTO JACK.DEMO.PRODUCT_FAQS VALUES
(16, NULL, 'Policy', 'What is the return policy?', 'We offer a 30-day return policy for all unused items in original packaging. Electronics must be returned within 15 days. Refunds are processed within 5-7 business days.'),
(17, NULL, 'Policy', 'How long does shipping take?', 'Standard shipping takes 5-7 business days. Express shipping (2-3 days) and overnight shipping are available for an additional fee. Free shipping on orders over $50.'),
(18, NULL, 'Policy', 'Do you offer price matching?', 'Yes, we offer price matching within 14 days of purchase if you find a lower price at an authorized retailer. Contact customer service with proof of the lower price.'),
(19, NULL, 'Policy', 'How can I track my order?', 'Once your order ships, you will receive an email with tracking information. You can also track your order by logging into your account on our website.'),
(20, NULL, 'Policy', 'What payment methods do you accept?', 'We accept all major credit cards (Visa, Mastercard, Amex, Discover), PayPal, Apple Pay, and Google Pay. Financing options are available for orders over $200.');

-- Create Cortex Search Service
CREATE OR REPLACE CORTEX SEARCH SERVICE JACK.DEMO.PRODUCT_FAQ_SEARCH
  ON answer
  ATTRIBUTES category, question
  WAREHOUSE = AICOLLEGE
  TARGET_LAG = '1 hour'
  AS (
    SELECT 
      faq_id,
      category,
      question,
      answer
    FROM JACK.DEMO.PRODUCT_FAQS
  );

-- Test search
SELECT SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
  'JACK.DEMO.PRODUCT_FAQ_SEARCH',
  '{"query": "return policy", "columns": ["category", "question", "answer"], "limit": 3}'
);
