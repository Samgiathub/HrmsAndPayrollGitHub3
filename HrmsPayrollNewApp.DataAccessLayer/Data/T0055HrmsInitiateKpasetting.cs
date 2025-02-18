using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0055HrmsInitiateKpasetting
{
    public decimal KpaInitiateId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public DateTime KpaStartDate { get; set; }

    public DateTime KpaEndDate { get; set; }

    public int InitiateStatus { get; set; }

    public int Year { get; set; }

    public int RmRequired { get; set; }

    public decimal? HodId { get; set; }

    public decimal? GhId { get; set; }

    public DateTime? EmpApprovedDate { get; set; }

    public DateTime? RmApprovedDate { get; set; }

    public DateTime? HodApprovedDate { get; set; }

    public DateTime? GhApprovedDate { get; set; }

    public string? EmpComment { get; set; }

    public string? RmComment { get; set; }

    public string? HodComment { get; set; }

    public string? GhComment { get; set; }

    public string DurationFromMonth { get; set; } = null!;

    public string DurationToMonth { get; set; } = null!;

    public string? ReviewType { get; set; }

    public int? SendToRm { get; set; }

    public string? Period { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0080EmpMaster? Gh { get; set; }

    public virtual T0080EmpMaster? Hod { get; set; }
}
