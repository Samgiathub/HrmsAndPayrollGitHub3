using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0115RcLtaTravelDetailLevel
{
    public decimal TranId { get; set; }

    public decimal RcLevelTranId { get; set; }

    public decimal RcTravelId { get; set; }

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

    public decimal CreatedBy { get; set; }

    public DateTime CreatedDate { get; set; }

    public decimal? AdExpMasterId { get; set; }

    public virtual T0050AdExpenseLimitMaster? AdExpMaster { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0115RcLevelApproval RcLevelTran { get; set; } = null!;
}
