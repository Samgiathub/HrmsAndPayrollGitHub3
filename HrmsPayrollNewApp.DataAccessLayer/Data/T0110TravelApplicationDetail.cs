using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0110TravelApplicationDetail
{
    public decimal TravelAppDetailId { get; set; }

    public decimal CmpId { get; set; }

    public decimal TravelAppId { get; set; }

    public string PlaceOfVisit { get; set; } = null!;

    public string TravelPurpose { get; set; } = null!;

    public decimal? InstructEmpId { get; set; }

    public decimal TravelModeId { get; set; }

    public DateTime FromDate { get; set; }

    public decimal Period { get; set; }

    public DateTime ToDate { get; set; }

    public string? Remarks { get; set; }

    public int? StateId { get; set; }

    public int? CityId { get; set; }

    public decimal? LocId { get; set; }

    public decimal? ProjectId { get; set; }

    public decimal? TravelTypeId { get; set; }

    public int? ReasonId { get; set; }

    public int? FromStateId { get; set; }

    public int? FromCityId { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster? InstructEmp { get; set; }

    public virtual T0100TravelApplication TravelApp { get; set; } = null!;
}
