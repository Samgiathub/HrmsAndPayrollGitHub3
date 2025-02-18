using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T9999AuditTrailEmpGeoLocationAssign
{
    public decimal AuditTrailId { get; set; }

    public decimal? EmpGeoLocationId { get; set; }

    public decimal? EmpGeoLocationDetailId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? GeoLocationId { get; set; }

    public int? Meter { get; set; }

    public decimal? CmpId { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public decimal? LoginId { get; set; }

    public DateTime? SystemDate { get; set; }
}
