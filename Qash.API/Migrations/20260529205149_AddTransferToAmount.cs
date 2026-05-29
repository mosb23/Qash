using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Qash.API.Migrations
{
    /// <inheritdoc />
    public partial class AddTransferToAmount : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                "ALTER TABLE \"Transactions\" ADD COLUMN IF NOT EXISTS \"ToAmount\" numeric(18,2);");

            migrationBuilder.Sql(
                """
                UPDATE "Transactions"
                SET "ToAmount" = "Amount"
                WHERE "TransactionType" = 3
                  AND "ToAmount" IS NULL;
                """);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                "ALTER TABLE \"Transactions\" DROP COLUMN IF EXISTS \"ToAmount\";");
        }
    }
}
