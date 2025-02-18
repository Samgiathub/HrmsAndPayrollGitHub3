using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040HrmsAppraisalRatingMaster
{
    public decimal RatingId { get; set; }

    public decimal RatingCmpId { get; set; }

    public string Rating { get; set; } = null!;

    public byte RatingIsActive { get; set; }

    public decimal RatingCreatedBy { get; set; }

    public DateTime RatingCreatedDate { get; set; }

    public decimal? RatingModifyBy { get; set; }

    public DateTime? RatingModifyDate { get; set; }
}
