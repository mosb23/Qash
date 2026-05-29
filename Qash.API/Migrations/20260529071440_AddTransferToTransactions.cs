using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Qash.API.Migrations
{
    /// <inheritdoc />
    public partial class AddTransferToTransactions : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                "DROP INDEX IF EXISTS \"IX_Budgets_ApplicationUserId_CategoryId_Year_Month\";");

            migrationBuilder.Sql(
                "ALTER TABLE \"Transactions\" ADD COLUMN IF NOT EXISTS \"ToWalletId\" uuid;");

            migrationBuilder.Sql(
                "CREATE INDEX IF NOT EXISTS \"IX_Transactions_ToWalletId\" ON \"Transactions\" (\"ToWalletId\");");

            migrationBuilder.Sql(
                "CREATE UNIQUE INDEX IF NOT EXISTS \"IX_Budgets_ApplicationUserId_CategoryId_Year_Month\" " +
                "ON \"Budgets\" (\"ApplicationUserId\", \"CategoryId\", \"Year\", \"Month\") " +
                "WHERE \"IsDeleted\" = FALSE;");

            migrationBuilder.Sql(
                "DO $$ BEGIN " +
                "IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'FK_Transactions_Wallets_ToWalletId') THEN " +
                "ALTER TABLE \"Transactions\" ADD CONSTRAINT \"FK_Transactions_Wallets_ToWalletId\" " +
                "FOREIGN KEY (\"ToWalletId\") REFERENCES \"Wallets\" (\"Id\") ON DELETE RESTRICT; " +
                "END IF; END $$;");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                "ALTER TABLE \"Transactions\" DROP CONSTRAINT IF EXISTS \"FK_Transactions_Wallets_ToWalletId\";");

            migrationBuilder.Sql(
                "DROP INDEX IF EXISTS \"IX_Transactions_ToWalletId\";");

            migrationBuilder.Sql(
                "DROP INDEX IF EXISTS \"IX_Budgets_ApplicationUserId_CategoryId_Year_Month\";");

            migrationBuilder.Sql(
                "ALTER TABLE \"Transactions\" DROP COLUMN IF EXISTS \"ToWalletId\";");

            migrationBuilder.Sql(
                "CREATE UNIQUE INDEX IF NOT EXISTS \"IX_Budgets_ApplicationUserId_CategoryId_Year_Month\" " +
                "ON \"Budgets\" (\"ApplicationUserId\", \"CategoryId\", \"Year\", \"Month\");");
        }
    }
}
