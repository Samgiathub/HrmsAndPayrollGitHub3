using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100TsApplication
{
    public decimal TimesheetId { get; set; }

    public decimal? EmployeeId { get; set; }

    public string? TimesheetPeriod { get; set; }

    public string? TimesheetType { get; set; }

    public DateTime? EntryDate { get; set; }

    public string? TotalTime { get; set; }

    public decimal? ProjectStatusId { get; set; }

    public decimal? ProjectId { get; set; }

    public decimal? TaskId { get; set; }

    public string? Description { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? CreatedBy { get; set; }

    public DateTime? CreatedDate { get; set; }

    public decimal? ModifyBy { get; set; }

    public DateTime? ModifyDate { get; set; }

    public string? Attachment { get; set; }

    public virtual T0010CompanyMaster? Cmp { get; set; }

    public virtual T0080EmpMaster? Employee { get; set; }

    public virtual T0040ProjectStatus? ProjectStatus { get; set; }

    public virtual ICollection<T0110TsApplicationDetail> T0110TsApplicationDetails { get; set; } = new List<T0110TsApplicationDetail>();

    public virtual ICollection<T0120TsApproval> T0120TsApprovals { get; set; } = new List<T0120TsApproval>();
}
