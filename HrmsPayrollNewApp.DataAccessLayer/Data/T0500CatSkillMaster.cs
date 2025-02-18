using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0500CatSkillMaster
{
    public decimal? CatId { get; set; }

    public decimal? CmpId { get; set; }

    public string? CatName { get; set; }

    public string? CatCode { get; set; }

    public decimal? IsMan { get; set; }

    public string? SortingNo { get; set; }

    public DateTime? RecordDate { get; set; }

    public decimal? CreatedBy { get; set; }
}
