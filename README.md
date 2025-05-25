# Studi Analisis Pro-kontra Metode Dakwah Gus Miftah di Media Sosial

Proyek ini dibuat untuk memenuhi tugas besar pembuatan proyek dalam mata kuliah Basis Data. Tujuan utama dari proyek ini adalah untuk mengubah data dari repositori penelitian kami (Google Sheets) ke dalam sistem basis data MySQL (MariaDB). Tabel tersebut merupakan tabel <i>unnormalized</i> yang akan kami ubah menjadi bentuk 3NF sebagai berikut:

erDiagram
    User ||--o{ Tweet : creates
    TweetCategory }o--|| Tweet : includes
    TweetCategory }o--|| Category : includes
    Category ||--o{ CategoryCount : has
    Category ||--o{ CategoryRatio : part_of

    User {
        int id PK
        varchar(15) username
        varchar(15) password
    }

    Tweet {
        int id PK
        int user_id FK
        varchar(150) content
        datetime created_at
    }

    Category {
        int id PK
        varchar(20) name
    }

    TweetCategory {
        int id PK
        int tweet_id FK
        int category_id FK
    }

    CategoryCount {
        int id PK
        int category_id FK
        date count_date
        int tweet_count
    }

    CategoryRatio {
        int id PK
        date ratio_date
        int category_id_1 FK
        int category_id_2 FK
        float ratio
    }