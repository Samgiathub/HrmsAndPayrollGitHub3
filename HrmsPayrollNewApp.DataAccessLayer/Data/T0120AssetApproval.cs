using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0120AssetApproval
{
    public decimal AssetApprovalId { get; set; }

    public decimal? AssetApplicationId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? BranchId { get; set; }

    public decimal? ReceiverId { get; set; }

    public string? Comments { get; set; }

    public string Status { get; set; } = null!;

    public decimal LoginId { get; set; }

    public DateTime SystemDate { get; set; }

    public DateTime? AssetApprovalDate { get; set; }

    public DateTime? AllocationDate { get; set; }

    public decimal? AppliedBy { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? ApplicationType { get; set; }

    public decimal? TransferEmpId { get; set; }

    public decimal? TransferBranchId { get; set; }

    public decimal? TransferDeptId { get; set; }

    public int? BranchForDept { get; set; }

    public int? TransferBranchForDept { get; set; }

    public virtual ICollection<T0110AssetInstallationDetail> T0110AssetInstallationDetails { get; set; } = new List<T0110AssetInstallationDetail>();

    public virtual ICollection<T0130AssetApprovalDet> T0130AssetApprovalDets { get; set; } = new List<T0130AssetApprovalDet>();

    public virtual ICollection<T0140AssetTransaction> T0140AssetTransactions { get; set; } = new List<T0140AssetTransaction>();
}
