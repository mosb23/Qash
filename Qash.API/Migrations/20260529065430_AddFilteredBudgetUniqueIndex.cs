using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Qash.API.Migrations
{
    /// <inheritdoc />
    public partial class AddFilteredBudgetUniqueIndex : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_Budgets_ApplicationUserId_CategoryId_Year_Month",
                table: "Budgets");

            migrationBuilder.CreateIndex(
                name: "IX_Budgets_ApplicationUserId_CategoryId_Year_Month",
                table: "Budgets",
                columns: new[] { "ApplicationUserId", "CategoryId", "Year", "Month" },
                unique: true,
                filter: "\"IsDeleted\" = FALSE");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_Budgets_ApplicationUserId_CategoryId_Year_Month",
                table: "Budgets");

            migrationBuilder.CreateIndex(
                name: "IX_Budgets_ApplicationUserId_CategoryId_Year_Month",
                table: "Budgets",
                columns: new[] { "ApplicationUserId", "CategoryId", "Year", "Month" },
                unique: true);
        }
    }
}
