using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0130TsApprovalDetail
{
    public decimal TsApprovalDetailId { get; set; }

    public decimal? TimesheetApprovalId { get; set; }

    public decimal? ProjectId { get; set; }

    public decimal? TaskId { get; set; }

    public string? Mon { get; set; }

    public string? Tue { get; set; }

    public string? Wed { get; set; }

    public string? Thu { get; set; }

    public string? Fri { get; set; }

    public string? Sat { get; set; }

    public string? Sun { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? CreatedBy { get; set; }

    public DateTime? CreatedDate { get; set; }

    public decimal? ModifyBy { get; set; }

    public DateTime? ModifyDate { get; set; }

    public virtual T0010CompanyMaster? Cmp { get; set; }

    public virtual T0040TsProjectMaster? Project { get; set; }

    public virtual T0040TaskMaster? Task { get; set; }

    public virtual T0120TsApproval? TimesheetApproval { get; set; }
}
