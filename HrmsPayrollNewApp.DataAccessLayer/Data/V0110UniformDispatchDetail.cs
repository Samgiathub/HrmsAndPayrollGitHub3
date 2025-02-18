using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0110UniformDispatchDetail
{
    public decimal UniDispId { get; set; }

    public decimal UniReqAppId { get; set; }

    public decimal UniId { get; set; }

    public string? UniName { get; set; }

    public decimal CmpId { get; set; }

    public decimal? UniReqAppCode { get; set; }

    public DateTime? RequestDate { get; set; }

    public decimal? RequestedByEmpId { get; set; }

    public DateTime? SystemDate { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? UniAmount { get; set; }

    public decimal? UniFabricPrice { get; set; }

    public int? UniPieces { get; set; }

    public decimal UniReqAppDetailId { get; set; }

    public decimal? UniStitchingPrice { get; set; }

    public decimal UniAprId { get; set; }

    public decimal? ApprovalCode { get; set; }

    public DateTime? ApprovalDate { get; set; }

    public string? ApproveStatus { get; set; }

    public decimal? ApprovedByEmpId { get; set; }

    public string? AlphaCode { get; set; }

    public string? EmpFullName { get; set; }

    public decimal? DispatchCode { get; set; }

    public DateTime? DispatchDate { get; set; }

    public int? RefundInstallment { get; set; }

    public int? DeductionInstallment { get; set; }

    public string? RefundStartDate { get; set; }

    public DateTime? DeductionStartDate { get; set; }

    public decimal? DispatchByEmpId { get; set; }

    public DateTime? SystemDatetime { get; set; }

    public string? BranchName { get; set; }

    public decimal BranchId { get; set; }

    public string? Comments { get; set; }

    public string ReqEmpFullName { get; set; } = null!;

    public string ReqEmpCode { get; set; } = null!;

    public string ReqEmpName { get; set; } = null!;

    public decimal? UniDeductInstallment { get; set; }

    public decimal? UniRefundInstallment { get; set; }
}
