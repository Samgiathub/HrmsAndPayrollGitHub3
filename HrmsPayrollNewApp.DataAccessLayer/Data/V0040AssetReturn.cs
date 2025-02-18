using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0040AssetReturn
{
    public string BrandName { get; set; } = null!;

    public string AssetName { get; set; } = null!;

    public decimal AssetId { get; set; }

    public DateTime? ApplicationDate { get; set; }

    public string? ApplicationStatus { get; set; }

    public string? ModelName { get; set; }

    public string SerialNo { get; set; } = null!;

    public decimal Expr1 { get; set; }

    public string? AssetId1 { get; set; }

    public string? AssetCode { get; set; }

    public decimal? EmpId { get; set; }

    public decimal CmpId { get; set; }

    public DateTime PurchaseDate { get; set; }

    public decimal BrandId { get; set; }

    public decimal? ApplicationType { get; set; }

    public decimal? BranchId { get; set; }

    public string? ApplicationCode { get; set; }

    public DateTime? ReturnDate { get; set; }

    public decimal? AssetMId { get; set; }

    public DateTime? AllocationDate { get; set; }

    public decimal? ReturnAssetApprovalId { get; set; }

    public string Status { get; set; } = null!;

    public decimal AssetApprovalId { get; set; }

    public decimal? AppliedBy { get; set; }

    public decimal? DeptId { get; set; }

    public string? ApprovalStatus { get; set; }

    public decimal? AssetApplicationId { get; set; }

    public decimal? TransferEmpId { get; set; }

    public decimal? TransferBranchId { get; set; }

    public decimal? TransferDeptId { get; set; }
}
