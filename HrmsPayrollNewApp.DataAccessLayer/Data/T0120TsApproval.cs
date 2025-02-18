using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0120TsApproval
{
    public decimal TimesheetApprovalId { get; set; }

    public decimal? ProjectStatusId { get; set; }

    public decimal? TimesheetId { get; set; }

    public decimal? EmployeeId { get; set; }

    public decimal? ApprovalBy { get; set; }

    public string? TimesheetPeriod { get; set; }

    public string? ApprovalRemarks { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? CreatedBy { get; set; }

    public DateTime? CreatedDate { get; set; }

    public decimal? ModifyBy { get; set; }

    public DateTime? ModifyDate { get; set; }

    public string? Attachment { get; set; }

    public virtual T0010CompanyMaster? Cmp { get; set; }

    public virtual T0080EmpMaster? Employee { get; set; }

    public virtual T0040ProjectStatus? ProjectStatus { get; set; }

    public virtual ICollection<T0130TsApprovalDetail> T0130TsApprovalDetails { get; set; } = new List<T0130TsApprovalDetail>();

    public virtual T0100TsApplication? Timesheet { get; set; }
}
