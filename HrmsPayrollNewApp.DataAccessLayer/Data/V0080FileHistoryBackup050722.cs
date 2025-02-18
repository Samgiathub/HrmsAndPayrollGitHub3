using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0080FileHistoryBackup050722
{
    public int FhId { get; set; }

    public decimal? FileAppId { get; set; }

    public decimal EmpId { get; set; }

    public decimal? FileAprId { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public string? ApplicationDate { get; set; }

    public string? ReportingManager { get; set; }

    public string? BranchName { get; set; }

    public string? DeptName { get; set; }

    public string? DesigName { get; set; }

    public int? HFStatusId { get; set; }

    public decimal? HFTypeId { get; set; }

    public string TransType { get; set; } = null!;

    public string? Status { get; set; }

    public string? FileType { get; set; }

    public string HFileNumber { get; set; } = null!;

    public string? HSubject { get; set; }

    public string HDescription { get; set; } = null!;

    public string? ProcessDate { get; set; }

    public decimal? BranchId { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? DesigId { get; set; }

    public decimal? SEmpId { get; set; }

    public decimal CmpId { get; set; }

    public string FileName { get; set; } = null!;

    public string? HFileAppDoc { get; set; }

    public decimal HForwardEmpId { get; set; }

    public decimal HSubmitEmpId { get; set; }

    public decimal HReviewEmpId { get; set; }

    public decimal HReviewedByEmpId { get; set; }

    public decimal HSEmpId { get; set; }

    public byte? RptLevel { get; set; }

    public string? HApprovalComments { get; set; }

    public decimal? HTranId { get; set; }

    public string? HTransType { get; set; }

    public string? UpdatedbyEmp { get; set; }

    public string? UpdatedDate { get; set; }

    public string? TblType { get; set; }

    public decimal? UpdatedbyEmpId { get; set; }

    public string? FwEmpCode { get; set; }

    public string? FwEmp { get; set; }

    public string? RwEmpCode { get; set; }

    public string? RwEmp { get; set; }

    public string? LoginName { get; set; }

    public string? LastUdatedby { get; set; }

    public string? UpdatedTime { get; set; }
}
