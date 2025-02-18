using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0090EmpHrDocDetailCandidate
{
    public int? Accetpeted { get; set; }

    public DateTime? AcceptedDate { get; set; }

    public decimal EmpDocId { get; set; }

    public decimal? HrDocId { get; set; }

    public decimal? EmpId { get; set; }

    public string? DocContent { get; set; }

    public string? DocTitle { get; set; }

    public decimal? CmpId { get; set; }

    public string AccepetedStatus { get; set; } = null!;

    public decimal? LoginId { get; set; }

    public string? DomainName { get; set; }

    public string? LoginName { get; set; }

    public string? ImageName { get; set; }

    public string? CmpName { get; set; }

    public string DeptName { get; set; } = null!;

    public string DesigName { get; set; } = null!;

    public string BranchName { get; set; } = null!;

    public string GrdName { get; set; } = null!;

    public decimal? GrdId { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? DesigId { get; set; }

    public decimal? BranchId { get; set; }

    public string? EmpCode { get; set; }

    public string? EmpFirstName { get; set; }

    public string? Gender { get; set; }

    public string? EmpFullName { get; set; }

    public string EmpFullNameNew { get; set; } = null!;

    public byte Type { get; set; }
}
