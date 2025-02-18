using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0060AppraisalEmployeeKpa
{
    public decimal EmpKpaId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public string? KpaContent { get; set; }

    public string? KpaTarget { get; set; }

    public decimal? KpaWeightage { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public int? Status { get; set; }

    public decimal? KpaTypeId { get; set; }

    public string? KpaPerformaceMeasure { get; set; }

    public DateTime? CompletionDate { get; set; }

    public string? AttachDocs { get; set; }

    public int? KpaInitiateId { get; set; }

    public string? Remarks { get; set; }

    public bool IsActive { get; set; }

    public int? SrNo { get; set; }

    public string? ApprovalLevel { get; set; }

    public DateTime? SystemDate { get; set; }

    public int? UserId { get; set; }

    public string? EmpComment { get; set; }

    public string? RmComment { get; set; }

    public string? HodComment { get; set; }

    public string? GhComment { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0040HrmsKpatypeMaster? KpaType { get; set; }
}
