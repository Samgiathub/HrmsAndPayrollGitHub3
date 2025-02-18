using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0500SubCatSkillMaster
{
    public decimal? SubCatId { get; set; }

    public decimal? CmpId { get; set; }

    public string? SubCatName { get; set; }

    public string? SubCatCode { get; set; }

    public decimal? CatId { get; set; }

    public DateTime? RecordDate { get; set; }

    public decimal? CreatedBy { get; set; }
}
