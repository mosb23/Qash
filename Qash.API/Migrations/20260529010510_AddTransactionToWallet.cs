using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Qash.API.Migrations
{
    /// <inheritdoc />
    public partial class AddTransactionToWallet : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<Guid>(
                name: "ToWalletId",
                table: "Transactions",
                type: "uuid",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_Transactions_ToWalletId",
                table: "Transactions",
                column: "ToWalletId");

            migrationBuilder.AddForeignKey(
                name: "FK_Transactions_Wallets_ToWalletId",
                table: "Transactions",
                column: "ToWalletId",
                principalTable: "Wallets",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Transactions_Wallets_ToWalletId",
                table: "Transactions");

            migrationBuilder.DropIndex(
                name: "IX_Transactions_ToWalletId",
                table: "Transactions");

            migrationBuilder.DropColumn(
                name: "ToWalletId",
                table: "Transactions");
        }
    }
}
