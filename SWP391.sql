-- =========================================================
-- CREATE DATABASE
-- =========================================================
IF DB_ID('OnlineCourseDB') IS NOT NULL
    DROP DATABASE OnlineCourseDB;
GO

CREATE DATABASE OnlineCourseDB;
GO

USE OnlineCourseDB;
GO


-- =========================================================
-- 1. USERS
-- =========================================================
CREATE TABLE Users (
    id              INT IDENTITY PRIMARY KEY,
    full_name       NVARCHAR(100) NOT NULL,
    email           NVARCHAR(100) NOT NULL UNIQUE,
    password_hash   NVARCHAR(255) NOT NULL,
    avatar_url      NVARCHAR(MAX),
    bio             NVARCHAR(MAX),
    role_id         INT NOT NULL,
    created_at      DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    updated_at      DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO


-- =========================================================
-- 2. USER ROLES
-- =========================================================
CREATE TABLE UserRole (
    id INT IDENTITY PRIMARY KEY,
    users_id INT NOT NULL,
    roles NVARCHAR(100) NOT NULL,

    CONSTRAINT FK_UserRole_User FOREIGN KEY (users_id)
        REFERENCES Users(id) ON DELETE NO ACTION
);
GO


-- =========================================================
-- 3. COURSES
-- =========================================================
CREATE TABLE Courses (
    id              INT IDENTITY PRIMARY KEY,
    instructor_id   INT NOT NULL,
    title           NVARCHAR(255) NOT NULL,
    slug            NVARCHAR(255) NOT NULL UNIQUE,
    description     NVARCHAR(MAX),
    thumbnail       NVARCHAR(MAX),
    level           NVARCHAR(30),
    price           DECIMAL(10,2) NOT NULL DEFAULT 0,
    promo_price     DECIMAL(10,2),
    status          NVARCHAR(30) NOT NULL DEFAULT 'draft',
    total_duration  INT,
    created_at      DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    updated_at      DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT FK_Courses_Instructor FOREIGN KEY (instructor_id)
        REFERENCES Users(id) ON DELETE NO ACTION
);
GO


-- =========================================================
-- 4. CATEGORIES
-- =========================================================
CREATE TABLE Categories (
    id      INT IDENTITY PRIMARY KEY,
    name    NVARCHAR(100) NOT NULL,
    slug    NVARCHAR(100) NOT NULL UNIQUE
);
GO


-- =========================================================
-- 5. COURSE_CATEGORIES (MANY-TO-MANY)
-- =========================================================
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


-- =========================================================
-- 6. CHAPTERS
-- =========================================================
CREATE TABLE Chapters (
    id          INT IDENTITY PRIMARY KEY,
    course_id   INT NOT NULL,
    title       NVARCHAR(255) NOT NULL,
    sort_order  INT NOT NULL DEFAULT 1,

    CONSTRAINT FK_Chapters_Course FOREIGN KEY (course_id)
        REFERENCES Courses(id) ON DELETE CASCADE
);
GO


-- =========================================================
-- 7. LESSONS
-- =========================================================
CREATE TABLE Lessons (
    id          INT IDENTITY PRIMARY KEY,
    chapter_id  INT NOT NULL,
    title       NVARCHAR(255) NOT NULL,
    video_url   NVARCHAR(MAX),
    duration    INT,
    preview     BIT NOT NULL DEFAULT 0,
    sort_order  INT NOT NULL DEFAULT 1,

    CONSTRAINT FK_Lessons_Chapter FOREIGN KEY (chapter_id)
        REFERENCES Chapters(id) ON DELETE CASCADE
);
GO


-- =========================================================
-- 8. LESSON RESOURCES
-- =========================================================
CREATE TABLE LessonResources (
    id             INT IDENTITY PRIMARY KEY,
    lesson_id      INT NOT NULL,
    resource_type  NVARCHAR(20) NOT NULL,
    resource_url   NVARCHAR(MAX) NOT NULL,

    CONSTRAINT FK_Resources_Lesson FOREIGN KEY (lesson_id)
        REFERENCES Lessons(id) ON DELETE CASCADE
);
GO


-- =========================================================
-- 9. REVIEWS
-- =========================================================
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


-- =========================================================
-- 10. COMMENTS (Q&A)
-- =========================================================
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


-- =========================================================
-- 11. ORDERS
-- =========================================================
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


-- =========================================================
-- 12. ORDER ITEMS
-- =========================================================
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


-- =========================================================
-- 13. COUPONS
-- =========================================================
CREATE TABLE Coupons (
    id               INT IDENTITY PRIMARY KEY,
    code             NVARCHAR(50) NOT NULL UNIQUE,
    discount_percent INT NOT NULL,
    max_uses         INT,
    expires_at       DATETIME2
);
GO


-- =========================================================
-- 14. USED COUPONS
-- =========================================================
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


-- =========================================================
-- 15. ENROLLMENTS
-- =========================================================
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


-- =========================================================
-- 16. LESSON PROGRESS
-- =========================================================
CREATE TABLE LessonProgress (
    id            INT IDENTITY PRIMARY KEY,
    user_id       INT NOT NULL,
    lesson_id     INT NOT NULL,
    is_completed  BIT NOT NULL DEFAULT 0,
    completed_at  DATETIME2,

    CONSTRAINT FK_Progress_User FOREIGN KEY (user_id)
        REFERENCES Users(id) ON DELETE NO ACTION,

    CONSTRAINT FK_Progress_Lesson FOREIGN KEY (lesson_id)
        REFERENCES Lessons(id) ON DELETE NO ACTION,

    CONSTRAINT UQ_Progress UNIQUE (user_id, lesson_id)
);
GO


-- =========================================================
-- 17. CERTIFICATES
-- =========================================================
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
