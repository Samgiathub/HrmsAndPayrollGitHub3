using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0110RcLtaTravelDetail
{
    public decimal RcTravelId { get; set; }

    public decimal RcAppId { get; set; }

    public decimal EmpId { get; set; }

    public decimal RcId { get; set; }

    public decimal CmpId { get; set; }

    public DateTime TravelDate { get; set; }

    public string? FromPlace { get; set; }

    public string? ToPlace { get; set; }

    public string? ModeOfTravel { get; set; }

    public decimal? Fare { get; set; }

    public string? FileName { get; set; }

    public byte? TaxException { get; set; }

    public string? BlockPeriod { get; set; }

    public byte? AbroadTravel { get; set; }

    public string? Remarks { get; set; }

    public int? CurrentYear { get; set; }

    public DateTime? FromDate { get; set; }

    public DateTime? ToDate { get; set; }

    public decimal? Amount { get; set; }

    public string? BillNo { get; set; }

    public DateTime? BillDate { get; set; }

    public decimal AprAmount { get; set; }

    public decimal? AdExpMasterId { get; set; }

    public virtual T0050AdExpenseLimitMaster? AdExpMaster { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0050AdMaster Rc { get; set; } = null!;

    public virtual T0100RcApplication RcApp { get; set; } = null!;
}
