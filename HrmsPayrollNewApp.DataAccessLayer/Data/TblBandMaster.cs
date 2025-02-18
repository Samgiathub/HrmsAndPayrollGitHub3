using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class TblBandMaster
{
    public decimal BandId { get; set; }

    public string? BandName { get; set; }

    public string? BandCode { get; set; }

    public decimal? SortingNo { get; set; }

    public int? CmpId { get; set; }

    public decimal? CreatedBy { get; set; }

    public DateTime? CreatedDate { get; set; }

    public bool? IsActive { get; set; }

    public string? IsActiveEffDate { get; set; }
}
