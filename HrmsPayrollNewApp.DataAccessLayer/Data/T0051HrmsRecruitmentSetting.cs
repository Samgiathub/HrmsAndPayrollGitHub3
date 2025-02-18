using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0051HrmsRecruitmentSetting
{
    public decimal RecSettingId { get; set; }

    public decimal RecApplicationId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? PostVacancyCmpId { get; set; }

    public decimal? PostVacancyEmpId { get; set; }

    public decimal? ShortlistCmpId { get; set; }

    public decimal? ShortlistEmpId { get; set; }

    public decimal? BusinessHeadCmpId { get; set; }

    public decimal? BusinessHeadEmpId { get; set; }

    public decimal CreatedBy { get; set; }

    public DateTime CreatedDate { get; set; }
}
