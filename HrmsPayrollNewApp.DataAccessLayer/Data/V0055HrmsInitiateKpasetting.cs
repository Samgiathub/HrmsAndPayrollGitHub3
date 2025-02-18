using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0055HrmsInitiateKpasetting
{
    public decimal KpaInitiateId { get; set; }

    public decimal EmpId { get; set; }

    public DateTime KpaStartDate { get; set; }

    public DateTime KpaEndDate { get; set; }

    public int InitiateStatus { get; set; }

    public string? InitiateStatus1 { get; set; }

    public int Year { get; set; }

    public int RmRequired { get; set; }

    public decimal? HodId { get; set; }

    public decimal? GhId { get; set; }

    public DateTime? EmpApprovedDate { get; set; }

    public DateTime? RmApprovedDate { get; set; }

    public string? EmpFullName { get; set; }

    public decimal? REmpId { get; set; }

    public string? ManagerName { get; set; }

    public string? HodName { get; set; }

    public string? GhName { get; set; }

    public string? DeptName { get; set; }

    public decimal? DeptId { get; set; }

    public decimal GrdId { get; set; }

    public string? GrdName { get; set; }

    public decimal? DesigId { get; set; }

    public string? DesigName { get; set; }

    public decimal CmpId { get; set; }

    public string? ReviewType { get; set; }

    public int SendToRm { get; set; }

    public string? EmpLeft { get; set; }

    public string DurationFromMonth { get; set; } = null!;

    public string DurationToMonth { get; set; } = null!;

    public string Period { get; set; } = null!;

    public string? QtrPeriod { get; set; }
}
