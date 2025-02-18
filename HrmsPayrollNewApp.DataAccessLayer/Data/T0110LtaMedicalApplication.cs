using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0110LtaMedicalApplication
{
    public decimal LmAppId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public DateTime? AppDate { get; set; }

    public string? AppCode { get; set; }

    public decimal? AppAmount { get; set; }

    public string? AppComments { get; set; }

    public string? FileName { get; set; }

    public string? FileName1 { get; set; }

    public DateTime? SystemDate { get; set; }

    public int AppStatus { get; set; }

    public DateTime? LeaveFromDate { get; set; }

    public DateTime? LeaveToDate { get; set; }

    public int? NoOfDays { get; set; }

    public int? TypeId { get; set; }

    public virtual ICollection<T0120LtaMedicalApproval> T0120LtaMedicalApprovals { get; set; } = new List<T0120LtaMedicalApproval>();

    public virtual ICollection<T0130LtaForDependant> T0130LtaForDependants { get; set; } = new List<T0130LtaForDependant>();

    public virtual ICollection<T0130LtaJurneyDetail> T0130LtaJurneyDetails { get; set; } = new List<T0130LtaJurneyDetail>();
}
