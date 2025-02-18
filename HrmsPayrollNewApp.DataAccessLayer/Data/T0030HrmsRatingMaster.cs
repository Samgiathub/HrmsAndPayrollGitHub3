using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0030HrmsRatingMaster
{
    public decimal RateId { get; set; }

    public decimal? RateValue { get; set; }

    public string? RateText { get; set; }

    public decimal? CmpId { get; set; }

    public string? DescriptionValue { get; set; }

    public virtual T0010CompanyMaster? Cmp { get; set; }

    public virtual ICollection<T0080Kpirating> T0080KpiratingRatingEmployeeNavigations { get; set; } = new List<T0080Kpirating>();

    public virtual ICollection<T0080Kpirating> T0080KpiratingRatingManagerNavigations { get; set; } = new List<T0080Kpirating>();

    public virtual ICollection<T0080Kpirating> T0080KpiratingRatingNavigations { get; set; } = new List<T0080Kpirating>();

    public virtual ICollection<T0100KpiratingLevel> T0100KpiratingLevels { get; set; } = new List<T0100KpiratingLevel>();
}
