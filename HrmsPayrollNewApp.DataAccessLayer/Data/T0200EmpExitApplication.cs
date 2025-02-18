using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0200EmpExitApplication
{
    public decimal ExitId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? BranchId { get; set; }

    public decimal? DesigId { get; set; }

    public DateTime? ResignationDate { get; set; }

    public DateTime LastDate { get; set; }

    public decimal? Reason { get; set; }

    public string? Comments { get; set; }

    public string Status { get; set; } = null!;

    public decimal? IsRehirable { get; set; }

    public decimal? SEmpId { get; set; }

    public string? Feedback { get; set; }

    public string? SupAck { get; set; }

    public DateTime? InterviewDate { get; set; }

    public string? InterviewTime { get; set; }

    public string IsProcess { get; set; } = null!;

    public string? EmailForwardTo { get; set; }

    public string? DriveDataForwardTo { get; set; }

    public decimal? RptMngId { get; set; }

    public DateTime? ApplicationDate { get; set; }

    public string? ExitAppDoc { get; set; }

    public string? ClearanceManagerId { get; set; }

    public decimal? UserId { get; set; }

    public string? IpAddress { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0080EmpMaster? SEmp { get; set; }

    public virtual ICollection<T0200ExitInterview> T0200ExitInterviews { get; set; } = new List<T0200ExitInterview>();
}
