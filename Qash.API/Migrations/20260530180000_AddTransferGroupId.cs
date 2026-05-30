using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Qash.API.Migrations;

/// <inheritdoc />
public partial class AddTransferGroupId : Migration
{
    /// <inheritdoc />
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.AddColumn<Guid>(
            name: "TransferGroupId",
            table: "Transactions",
            type: "uuid",
            nullable: true);

        migrationBuilder.AddColumn<Guid>(
            name: "LinkedTransactionId",
            table: "Transactions",
            type: "uuid",
            nullable: true);

        migrationBuilder.CreateIndex(
            name: "IX_Transactions_TransferGroupId",
            table: "Transactions",
            column: "TransferGroupId");
    }

    /// <inheritdoc />
    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropIndex(
            name: "IX_Transactions_TransferGroupId",
            table: "Transactions");

        migrationBuilder.DropColumn(
            name: "LinkedTransactionId",
            table: "Transactions");

        migrationBuilder.DropColumn(
            name: "TransferGroupId",
            table: "Transactions");
    }
}
