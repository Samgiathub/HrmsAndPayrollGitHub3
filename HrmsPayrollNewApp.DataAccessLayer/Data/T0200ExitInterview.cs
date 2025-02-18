using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0200ExitInterview
{
    public decimal InterviewId { get; set; }

    public decimal EmpId { get; set; }

    public decimal? ExitId { get; set; }

    public decimal? QuestionId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? LoginId { get; set; }

    public DateTime PostedDate { get; set; }

    public string IntStatus { get; set; } = null!;

    public decimal? IsView { get; set; }

    public byte IsActive { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0200EmpExitApplication? Exit { get; set; }
}
