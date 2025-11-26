CREATE DATABASE OnlineCourseDB;
GO

USE OnlineCourseDB;
GO


---------------------------------------------------------
-- 1. USERS
---------------------------------------------------------
CREATE TABLE Users (
    id              INT IDENTITY PRIMARY KEY,
    full_name       NVARCHAR(100) NOT NULL,
    email           NVARCHAR(100) NOT NULL UNIQUE,
    password_hash   NVARCHAR(255) NOT NULL,
    avatar_url      NVARCHAR(MAX) NULL,
    bio             NVARCHAR(MAX) NULL,
    role            NVARCHAR(20) NOT NULL DEFAULT 'student',
    created_at      DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    updated_at      DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO


---------------------------------------------------------
-- 2. COURSES
---------------------------------------------------------
CREATE TABLE Courses (
    id              INT IDENTITY PRIMARY KEY,
    instructor_id   INT NOT NULL,
    title           NVARCHAR(255) NOT NULL,
    slug            NVARCHAR(255) NOT NULL UNIQUE,
    description     NVARCHAR(MAX) NULL,
    thumbnail       NVARCHAR(MAX) NULL,
    level           NVARCHAR(30) NULL,
    price           DECIMAL(10,2) NOT NULL DEFAULT 0,
    promo_price     DECIMAL(10,2) NULL,
    status          NVARCHAR(30) NOT NULL DEFAULT 'draft',
    total_duration  INT NULL,
    created_at      DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    updated_at      DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT FK_Courses_Instructor FOREIGN KEY (instructor_id)
        REFERENCES Users(id) ON DELETE NO ACTION
);
GO


---------------------------------------------------------
-- 3. CATEGORIES
---------------------------------------------------------
CREATE TABLE Categories (
    id      INT IDENTITY PRIMARY KEY,
    name    NVARCHAR(100) NOT NULL,
    slug    NVARCHAR(100) NOT NULL UNIQUE
);
GO


---------------------------------------------------------
-- 4. COURSE_CATEGORIES (Many-to-Many)
---------------------------------------------------------
CREATE TABLE CourseCategories (
    id          INT IDENTITY PRIMARY KEY,
    course_id   INT NOT NULL,
    category_id INT NOT NULL,

    CONSTRAINT FK_CC_Course FOREIGN KEY (course_id)
        REFERENCES Courses(id) ON DELETE CASCADE,

    CONSTRAINT FK_CC_Category FOREIGN KEY (category_id)
        REFERENCES Categories(id) ON DELETE CASCADE,

    CONSTRAINT UQ_Course_Category UNIQUE (course_id, category_id)
);
GO


---------------------------------------------------------
-- 5. CHAPTERS
---------------------------------------------------------
CREATE TABLE Chapters (
    id          INT IDENTITY PRIMARY KEY,
    course_id   INT NOT NULL,
    title       NVARCHAR(255) NOT NULL,
    sort_order  INT NOT NULL DEFAULT 1,

    CONSTRAINT FK_Chapters_Course FOREIGN KEY (course_id)
        REFERENCES Courses(id) ON DELETE CASCADE
);
GO


---------------------------------------------------------
-- 6. LESSONS
---------------------------------------------------------
CREATE TABLE Lessons (
    id          INT IDENTITY PRIMARY KEY,
    chapter_id  INT NOT NULL,
    title       NVARCHAR(255) NOT NULL,
    video_url   NVARCHAR(MAX) NULL,
    duration    INT NULL,
    preview     BIT NOT NULL DEFAULT 0,
    sort_order  INT NOT NULL DEFAULT 1,

    CONSTRAINT FK_Lessons_Chapter FOREIGN KEY (chapter_id)
        REFERENCES Chapters(id) ON DELETE CASCADE
);
GO


---------------------------------------------------------
-- 7. LESSON_RESOURCES
---------------------------------------------------------
CREATE TABLE LessonResources (
    id             INT IDENTITY PRIMARY KEY,
    lesson_id      INT NOT NULL,
    resource_type  NVARCHAR(20) NOT NULL,
    resource_url   NVARCHAR(MAX) NOT NULL,

    CONSTRAINT FK_Resources_Lesson FOREIGN KEY (lesson_id)
        REFERENCES Lessons(id) ON DELETE CASCADE
);
GO


---------------------------------------------------------
-- 8. REVIEWS
---------------------------------------------------------
CREATE TABLE Reviews (
    id          INT IDENTITY PRIMARY KEY,
    course_id   INT NOT NULL,
    user_id     INT NOT NULL,
    rating      INT NOT NULL,
    comment     NVARCHAR(MAX),
    created_at  DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT FK_Reviews_Course FOREIGN KEY (course_id)
        REFERENCES Courses(id) ON DELETE CASCADE,

    CONSTRAINT FK_Reviews_User FOREIGN KEY (user_id)
        REFERENCES Users(id) ON DELETE NO ACTION
);
GO


---------------------------------------------------------
-- 9. COMMENTS (Q&A)
---------------------------------------------------------
CREATE TABLE Comments (
    id          INT IDENTITY PRIMARY KEY,
    lesson_id   INT NOT NULL,
    user_id     INT NOT NULL,
    content     NVARCHAR(MAX) NOT NULL,
    parent_id   INT NULL,
    created_at  DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT FK_Comments_Lesson FOREIGN KEY (lesson_id)
        REFERENCES Lessons(id) ON DELETE CASCADE,

    CONSTRAINT FK_Comments_User FOREIGN KEY (user_id)
        REFERENCES Users(id) ON DELETE NO ACTION,

    CONSTRAINT FK_Comments_Parent FOREIGN KEY (parent_id)
        REFERENCES Comments(id) ON DELETE NO ACTION
);
GO


---------------------------------------------------------
-- 10. ORDERS
---------------------------------------------------------
CREATE TABLE Orders (
    id              INT IDENTITY PRIMARY KEY,
    user_id         INT NOT NULL,
    total_amount    DECIMAL(10,2) NOT NULL DEFAULT 0,
    payment_method  NVARCHAR(30) NOT NULL DEFAULT 'bank',
    status          NVARCHAR(30) NOT NULL DEFAULT 'pending',
    created_at      DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    updated_at      DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT FK_Orders_User FOREIGN KEY (user_id)
        REFERENCES Users(id) ON DELETE NO ACTION
);
GO


---------------------------------------------------------
-- 11. ORDER_ITEMS
---------------------------------------------------------
CREATE TABLE OrderItems (
    id        INT IDENTITY PRIMARY KEY,
    order_id  INT NOT NULL,
    course_id INT NOT NULL,
    price     DECIMAL(10,2) NOT NULL,

    CONSTRAINT FK_OrderItems_Order FOREIGN KEY (order_id)
        REFERENCES Orders(id) ON DELETE CASCADE,

    CONSTRAINT FK_OrderItems_Course FOREIGN KEY (course_id)
        REFERENCES Courses(id) ON DELETE NO ACTION
);
GO


---------------------------------------------------------
-- 12. COUPONS
---------------------------------------------------------
CREATE TABLE Coupons (
    id               INT IDENTITY PRIMARY KEY,
    code             NVARCHAR(50) NOT NULL UNIQUE,
    discount_percent INT NOT NULL,
    max_uses         INT NULL,
    expires_at       DATETIME2 NULL
);
GO


---------------------------------------------------------
-- 13. USED_COUPONS
---------------------------------------------------------
CREATE TABLE UsedCoupons (
    id         INT IDENTITY PRIMARY KEY,
    user_id    INT NOT NULL,
    coupon_id  INT NOT NULL,
    used_at    DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT FK_UsedCoupon_User FOREIGN KEY (user_id)
        REFERENCES Users(id) ON DELETE NO ACTION,

    CONSTRAINT FK_UsedCoupon_Coupon FOREIGN KEY (coupon_id)
        REFERENCES Coupons(id) ON DELETE CASCADE,

    CONSTRAINT UQ_User_Coupon UNIQUE (user_id, coupon_id)
);
GO


---------------------------------------------------------
-- 14. ENROLLMENTS
---------------------------------------------------------
CREATE TABLE Enrollments (
    id           INT IDENTITY PRIMARY KEY,
    user_id      INT NOT NULL,
    course_id    INT NOT NULL,
    enrolled_at  DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT FK_Enroll_User FOREIGN KEY (user_id)
        REFERENCES Users(id) ON DELETE NO ACTION,

    CONSTRAINT FK_Enroll_Course FOREIGN KEY (course_id)
        REFERENCES Courses(id) ON DELETE NO ACTION,

    CONSTRAINT UQ_Enrollment UNIQUE (user_id, course_id)
);
GO


---------------------------------------------------------
-- 15. LESSON_PROGRESS
---------------------------------------------------------
CREATE TABLE LessonProgress (
    id            INT IDENTITY PRIMARY KEY,
    user_id       INT NOT NULL,
    lesson_id     INT NOT NULL,
    is_completed  BIT NOT NULL DEFAULT 0,
    completed_at  DATETIME2 NULL,

    CONSTRAINT FK_Progress_User FOREIGN KEY (user_id)
        REFERENCES Users(id) ON DELETE NO ACTION,

    CONSTRAINT FK_Progress_Lesson FOREIGN KEY (lesson_id)
        REFERENCES Lessons(id) ON DELETE NO ACTION,

    CONSTRAINT UQ_Progress UNIQUE (user_id, lesson_id)
);
GO


---------------------------------------------------------
-- 16. CERTIFICATES
---------------------------------------------------------
CREATE TABLE Certificates (
    id              INT IDENTITY PRIMARY KEY,
    user_id         INT NOT NULL,
    course_id       INT NOT NULL,
    certificate_url NVARCHAR(MAX) NOT NULL,
    issued_at       DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT FK_Cert_User FOREIGN KEY (user_id)
        REFERENCES Users(id) ON DELETE NO ACTION,

    CONSTRAINT FK_Cert_Course FOREIGN KEY (course_id)
        REFERENCES Courses(id) ON DELETE NO ACTION,

    CONSTRAINT UQ_Certificate UNIQUE (user_id, course_id)
);
GO
