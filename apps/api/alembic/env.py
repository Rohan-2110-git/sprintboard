import os, sys
from alembic import context
from sqlalchemy import create_engine, pool

# add project root to path
this_dir = os.path.dirname(__file__)
proj_root = os.path.abspath(os.path.join(this_dir, "..", "..", ".."))
sys.path.append(proj_root)

from apps.api.db import Base  # noqa

config = context.config
# prefer env var if not set in ini
if not config.get_main_option("sqlalchemy.url"):
    config.set_main_option("sqlalchemy.url", os.getenv("DATABASE_URL", "sqlite:///./sprintboard.db"))

target_metadata = Base.metadata

def run_migrations_offline():
    url = config.get_main_option("sqlalchemy.url")
    context.configure(
        url=url,
        target_metadata=target_metadata,
        literal_binds=True,
        compare_type=True,
    )
    with context.begin_transaction():
        context.run_migrations()

def run_migrations_online():
    connectable = create_engine(
        config.get_main_option("sqlalchemy.url"),
        poolclass=pool.NullPool,
        future=True,
    )
    with connectable.connect() as connection:
        context.configure(connection=connection, target_metadata=target_metadata, compare_type=True)
        with context.begin_transaction():
            context.run_migrations()

if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
