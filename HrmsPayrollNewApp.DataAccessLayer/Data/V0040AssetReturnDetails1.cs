using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0040AssetReturnDetails1
{
    public string BrandName { get; set; } = null!;

    public string AssetName { get; set; } = null!;

    public decimal AssetId { get; set; }

    public string ApplicationDate { get; set; } = null!;

    public string ApplicationStatus { get; set; } = null!;

    public string ModelName { get; set; } = null!;

    public string SerialNo { get; set; } = null!;

    public DateTime? AllocationDate { get; set; }

    public string AssetCode { get; set; } = null!;

    public decimal? EmpId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? AssetMId { get; set; }

    public decimal? BranchId { get; set; }

    public decimal BrandId { get; set; }

    public DateTime PurchaseDate { get; set; }

    public DateTime? ReturnDate { get; set; }

    public string? AssetStatus { get; set; }

    public decimal AssetApprovalId { get; set; }

    public decimal? AssetApplicationId { get; set; }

    public decimal? ReturnAssetApprovalId { get; set; }

    public decimal? ApplicationType { get; set; }

    public bool? Allocation { get; set; }

    public decimal? DeptId { get; set; }

    public string Status { get; set; } = null!;

    public string? ApprovalStatus { get; set; }

    public decimal? TransferEmpId { get; set; }

    public decimal? TransferBranchId { get; set; }

    public decimal? TransferDeptId { get; set; }

    public decimal AssetApprDetId { get; set; }

    public decimal? TransferId { get; set; }

    public string Description { get; set; } = null!;

    public int? BranchForDept { get; set; }

    public int? TransferBranchForDept { get; set; }
}
