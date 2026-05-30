using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Qash.API.Migrations
{
    /// <inheritdoc />
    public partial class AddMultiCurrencyFields : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "PreferredCurrency",
                table: "Users",
                type: "character varying(10)",
                maxLength: 10,
                nullable: false,
                defaultValue: "USD");

            migrationBuilder.AddColumn<string>(
                name: "SourceCurrency",
                table: "Transactions",
                type: "character varying(10)",
                maxLength: 10,
                nullable: false,
                defaultValue: "USD");

            migrationBuilder.AddColumn<string>(
                name: "DestinationCurrency",
                table: "Transactions",
                type: "character varying(10)",
                maxLength: 10,
                nullable: true);

            migrationBuilder.AddColumn<decimal>(
                name: "AmountInBaseCurrency",
                table: "Transactions",
                type: "numeric(18,2)",
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<decimal>(
                name: "ExchangeRateUsed",
                table: "Transactions",
                type: "numeric(18,6)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Currency",
                table: "Budgets",
                type: "character varying(10)",
                maxLength: 10,
                nullable: false,
                defaultValue: "USD");

            migrationBuilder.AddColumn<string>(
                name: "Currency",
                table: "SavingGoals",
                type: "character varying(10)",
                maxLength: 10,
                nullable: false,
                defaultValue: "USD");

            migrationBuilder.Sql(
                """
                UPDATE "Transactions" t
                SET "SourceCurrency" = UPPER(COALESCE(NULLIF(w."Currency", ''), 'USD')),
                    "AmountInBaseCurrency" = ROUND(
                        t."Amount" / CASE UPPER(COALESCE(NULLIF(w."Currency", ''), 'USD'))
                            WHEN 'USD' THEN 1.00
                            WHEN 'EGP' THEN 49.50
                            WHEN 'EUR' THEN 0.86
                            WHEN 'GBP' THEN 0.74
                            WHEN 'JPY' THEN 143.20
                            ELSE 1.00
                        END, 2),
                    "DestinationCurrency" = CASE
                        WHEN t."ToWalletId" IS NOT NULL THEN UPPER(COALESCE(NULLIF(tw."Currency", ''), 'USD'))
                        ELSE NULL
                    END,
                    "ExchangeRateUsed" = CASE
                        WHEN t."ToWalletId" IS NOT NULL AND t."Amount" <> 0 THEN
                            ROUND(COALESCE(t."ToAmount", t."Amount") / t."Amount", 6)
                        WHEN t."ToWalletId" IS NULL THEN
                            ROUND(1.00 / CASE UPPER(COALESCE(NULLIF(w."Currency", ''), 'USD'))
                                WHEN 'USD' THEN 1.00
                                WHEN 'EGP' THEN 49.50
                                WHEN 'EUR' THEN 0.86
                                WHEN 'GBP' THEN 0.74
                                WHEN 'JPY' THEN 143.20
                                ELSE 1.00
                            END, 6)
                        ELSE NULL
                    END
                FROM "Wallets" w
                LEFT JOIN "Wallets" tw ON tw."Id" = t."ToWalletId"
                WHERE t."WalletId" = w."Id";
                """);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "PreferredCurrency",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "SourceCurrency",
                table: "Transactions");

            migrationBuilder.DropColumn(
                name: "DestinationCurrency",
                table: "Transactions");

            migrationBuilder.DropColumn(
                name: "AmountInBaseCurrency",
                table: "Transactions");

            migrationBuilder.DropColumn(
                name: "ExchangeRateUsed",
                table: "Transactions");

            migrationBuilder.DropColumn(
                name: "Currency",
                table: "Budgets");

            migrationBuilder.DropColumn(
                name: "Currency",
                table: "SavingGoals");
        }
    }
}
