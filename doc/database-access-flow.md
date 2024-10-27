# Database Access Flow

As the database follows a lazy-initialization pattern, it is not immediately clear how the database will be initialized.

Although `ensureAvailability` is called redundantly, it's impact on performance is little.
So, I will leave it as it until performance problem occurs.
(If all tables are used after `use`-instanciation, ensuring availability is unnecessary for all methods except `use` itself.)
...well, I will refine it later.
