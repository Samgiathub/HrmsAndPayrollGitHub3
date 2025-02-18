using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0120CompOffApproval
{
    public decimal CompOffApprId { get; set; }

    public decimal? CompOffAppId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal? SEmpId { get; set; }

    public DateTime ExtraWorkDate { get; set; }

    public DateTime ApproveDate { get; set; }

    public string ExtraWorkHours { get; set; } = null!;

    public string SanctionedHours { get; set; } = null!;

    public string? ExtraWorkReason { get; set; }

    public string ApproveStatus { get; set; } = null!;

    public string? ApproveComments { get; set; }

    public string? ContactNo { get; set; }

    public string? EmailId { get; set; }

    public decimal LoginId { get; set; }

    public DateTime SystemDatetime { get; set; }

    public decimal CompOffDays { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0100CompOffApplication? CompOffApp { get; set; }

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0080EmpMaster? SEmp { get; set; }
}
